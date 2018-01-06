Shader "Custom/Lambertian_fragment" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM

				#include "UnityCG.cginc"
				#pragma vertex vert
				#pragma fragment frag
				uniform float4 _Color;
				uniform sampler2D _MainTex;
				uniform float4 _LightColor0;

				struct vertIn {
					float4 pos : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct vertOut {
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0;
					float3 normal : TEXCOORD1;
					float4 tex : TEXCOORD2;
				};

				vertOut vert(vertIn i) {
					vertOut o;
					o.pos = mul(UNITY_MATRIX_MVP, i.pos);
					o.worldPos = mul(unity_ObjectToWorld, i.pos);
					o.tex = i.texcoord;
					o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
					return o;
				}

				float4 frag(vertOut i) : SV_TARGET{
					float3 normalDir = normalize(i.normal); //Renormalizing in case it isnt a unit length after interpolation
					float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
					float3 lightDir;
					float attenuation;
					float4 textureColor = tex2D(_MainTex, i.tex.xy);

					if (0.0 == _WorldSpaceLightPos0.w) { //If Directional light
						attenuation = 1.0;
						lightDir = normalize(_WorldSpaceLightPos0.xyz);
					}
					else { //else if point or spot light
						float3 pointToLight = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
						attenuation = 1 / length(pointToLight);
						lightDir = normalize(pointToLight);
					}

					float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));
					return float4(ambientLight + diffuseReflection, 1.0);
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
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform sampler2D _MainTex;
			uniform float4 _LightColor0;

			struct vertIn {
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct vertOut {
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float4 tex : TEXCOORD2;
			};

			vertOut vert(vertIn i) {
				vertOut o;
				o.pos = mul(UNITY_MATRIX_MVP, i.pos);
				o.worldPos = mul(unity_ObjectToWorld, i.pos);
				o.tex = i.texcoord;
				o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz); //transform normal to world space done by multiplying normal with the transpose of the inverse Model matrix
				return o;
			}

			float4 frag(vertOut i) : SV_TARGET{
				float3 normalDir = normalize(i.normal); //Renormalizing in case it isnt a unit length after interpolation
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
				float3 lightDir;
				float attenuation;
				float4 textureColor = tex2D(_MainTex, i.tex.xy);

				if (0.0 == _WorldSpaceLightPos0.w) { //If Directional light
					attenuation = 1.0;
					lightDir = normalize(_WorldSpaceLightPos0.xyz);
				}
				else { //else if point or spot light
					float3 pointToLight = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
					attenuation = 1 / length(pointToLight);
					lightDir = normalize(pointToLight);
				}

				float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDir, lightDir));
				return float4(diffuseReflection, 1.0);
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}
