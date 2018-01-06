Shader "Custom/Gouraud" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM

				#include "UnityCG.cginc"
				#pragma vertex vert
				#pragma fragment frag	
				uniform float4 _Color;
				uniform float4 _LightColor0;

				struct vertIn {
					float4 pos : POSITION;
					float3 normal : NORMAL;
				};

				struct vertOut {
					float4 pos : SV_POSITION;
					float4 col : COLOR;
				};

				vertOut vert(vertIn i) {
					vertOut o;
					o.pos = mul(UNITY_MATRIX_MVP, i.pos);

					float4 worldPos = mul(unity_ObjectToWorld, i.pos);
					float3 normalDir = normalize(mul(i.normal, unity_WorldToObject).xyz); //Renormalizing in case it isnt a unit length after interpolation
					float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);
					float3 lightDir;
					float attenuation;

					if (0.0 == _WorldSpaceLightPos0.w) { //If Directional light
						attenuation = 1.0;
						lightDir = normalize(_WorldSpaceLightPos0.xyz);
					}
					else { //else if point or spot light
						float3 vertexToLight = _WorldSpaceLightPos0.xyz - worldPos.xyz;
						attenuation = 1 / length(vertexToLight);
						lightDir = normalize(vertexToLight);
					}

					float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));
					o.col = float4(ambientLight + diffuseReflection, 1.0);

					return o;
				}

				float4 frag(vertOut i) : SV_TARGET{
					return i.col;
				}

			ENDCG
		}

		Pass{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One
			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag	
			uniform float4 _Color;
			uniform float4 _LightColor0;

			struct vertIn {
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};


			struct vertOut {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			vertOut vert(vertIn i) {
				vertOut o;
				o.pos = mul(UNITY_MATRIX_MVP, i.pos);

				float4 worldPos = mul(unity_ObjectToWorld, i.pos);
				float3 normalDir = normalize(mul(i.normal, unity_WorldToObject).xyz); //Renormalizing in case it isnt a unit length after interpolation
				float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);
				float3 lightDir;
				float attenuation;

				if (0.0 == _WorldSpaceLightPos0.w) { //If Directional light
					attenuation = 1.0;
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
				}
				else { //else if point or spot light
					float3 vertexToLight = _WorldSpaceLightPos0.xyz - worldPos.xyz;
					attenuation = 1 / length(vertexToLight);
					lightDir = normalize(vertexToLight);
				}

				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));
				o.col = float4(diffuseReflection, 1.0);

				return o;
			}

			float4 frag(vertOut i) : SV_TARGET{
				return i.col;
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
