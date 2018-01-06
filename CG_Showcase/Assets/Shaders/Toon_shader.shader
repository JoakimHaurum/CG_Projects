Shader "Custom/Toon_shader" {
	Properties{
		_Color("Lit diffuse color", Color) = (1,1,1,1)
		_UnlitColor("Unlit diffuse color", Color) = (0.5,0.5,0.5,1)
		_DiffuseThreshold("Threshold - diffuse color", Range(0,1)) = 0.2
		_Outline("Outline color", Color) = (0,0,0,1)
		_LitOutlineThickness("Lit Outline thickness", Float) = 0.1
		_UnlitOutlineThickness("Unlit Outline Thickness", Float) = 0.4
		_SpecColor("Spec Material Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
	}
		SubShader{
			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM

					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
					uniform float4 _LightColor0;
					uniform float4 _Color;
					uniform float4 _UnlitColor;
					uniform float4 _Outline;
					uniform float4 _SpecColor;
					uniform float _DiffuseThreshold;
					uniform float _LitOutlineThickness;
					uniform float _UnlitOutlineThickness;
					uniform float _Shininess;

					struct vertIn {
						float4 pos : POSITION;
						float3 normal : NORMAL;
					};

					struct vertOut {
						float4 pos : SV_POSITION;
						float4 worldPos : TEXCOORD0;
						float3 normal : TEXCOORD1;
					};

					vertOut vert(vertIn i) {
						vertOut o;
						o.pos = mul(UNITY_MATRIX_MVP, i.pos);
						o.worldPos = mul(unity_ObjectToWorld, i.pos);
						o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
						return o;
					}

					float4 frag(vertOut i) : SV_TARGET{
						float3 normalDir = normalize(i.normal);
						float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
						float3 lightDir;
						float attenuation;

						if (_WorldSpaceLightPos0.w == 0) { //Directional light
							attenuation = 1.0;
							lightDir = normalize(_WorldSpaceLightPos0.xyz);
						}
						else { //else if point or spot light
							float3 pointToLight = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
							attenuation = 1 / length(pointToLight);
							lightDir = normalize(pointToLight);
						}

						float3 fragColor = _UnlitColor;
						float dotLN = dot(normalDir, lightDir);


						// Diffuse color
						if (attenuation* max(0.0, dotLN) > _DiffuseThreshold) {
							fragColor = _LightColor0.rgb * _Color.rgb;
						}

						// Outline
						if (dot(viewDir, normalDir) < lerp(_UnlitOutlineThickness, _LitOutlineThickness, max(0.0, dot(normalDir, lightDir)))) {
							fragColor = _LightColor0.rgb * _Outline.rgb;
						}

						//Highlights
						if (dotLN > 0.0 && attenuation * pow(max(0.0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess) > 0.5) {
							fragColor = _SpecColor.a * _LightColor0.rgb * _SpecColor.rgb + (1.0 - _SpecColor.a) * fragColor;
						}

						return float4(fragColor, 1.0);
					}
			ENDCG
		}

		Pass{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				uniform float4 _LightColor0;
				uniform float4 _Color;
				uniform float4 _UnlitColor;
				uniform float4 _Outline;
				uniform float4 _SpecColor;
				uniform float _DiffuseThreshold;
				uniform float _LitOutlineThickness;
				uniform float _UnlitOutlineThickness;
				uniform float _Shininess;

				struct vertIn {
					float4 pos : POSITION;
					float3 normal : NORMAL;
				};

				struct vertOut {
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0;
					float3 normal : TEXCOORD1;
				};

				vertOut vert(vertIn i) {
					vertOut o;
					o.pos = mul(UNITY_MATRIX_MVP, i.pos);
					o.worldPos = mul(unity_ObjectToWorld, i.pos);
					o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
					return o;
				}

				float4 frag(vertOut i) : SV_TARGET{
					float3 normalDir = normalize(i.normal);
					float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
					float3 lightDir;
					float attenuation;

					if (_WorldSpaceLightPos0.w == 0) { //Directional light
						attenuation = 1.0;
						lightDir = normalize(_WorldSpaceLightPos0.xyz);
					}
					else { //else if point or spot light
						float3 pointToLight = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
						attenuation = 1 / length(pointToLight);
						lightDir = normalize(pointToLight);
					}

					float4 fragColor = float4(0.0, 0.0, 0.0, 0.0);
					float dotLN = dot(normalDir, lightDir);

					//Highlights
					if (dotLN > 0.0 && attenuation * pow(max(0.0, dot(reflect(-lightDir, normalDir), viewDir)), _Shininess) > 0.5) {
						fragColor = float4(_LightColor0.rgb, 1.0) * _SpecColor;
					}

					return fragColor;
				}
			ENDCG
		}
	}
	FallBack "Specular"
}
