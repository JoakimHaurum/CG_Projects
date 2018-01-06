Shader "Custom/Ward" {
		Properties{
			_Color("Color", Color) = (1,1,1,1)
			_SpecColor("Specular Color", Color) = (1,1,1,1)
			_AlphaX("Material property x-dir", Float) = 1
			_AlphaY("Material property y-dir", Float) = 1
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
				uniform float4 _SpecColor;
				uniform sampler2D _MainTex;
				uniform float4 _LightColor0;
				uniform float _AlphaX;
				uniform float _AlphaY;

				struct vertIn {
					float4 pos : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
				};

				struct vertOut {
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0;
					float3 normal : TEXCOORD1;
					float4 tex : TEXCOORD2;
					float3 viewDir : TEXCOORD3;
					float3 tangent : TEXCOORD4;
				};

				vertOut vert(vertIn i) {
					vertOut o;
					o.pos = mul(UNITY_MATRIX_MVP, i.pos);
					o.worldPos = mul(unity_ObjectToWorld, i.pos);
					o.tex = i.texcoord;
					o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
					o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos.xyz);
					o.tangent = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz,0.0).xyz));
					return o;
				}

				float4 frag(vertOut i) : SV_TARGET{
					float3 normalDir = normalize(i.normal); //Renormalizing in case it isnt a unit length after interpolation
					float3 viewDir = normalize(i.viewDir);
					float3 tangentDir = normalize(i.tangent);
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

					float3 halfWayDir = normalize(lightDir + viewDir);
					float3 binormal = cross(normalDir, tangentDir);
					float dotLN = dot(lightDir, normalDir);

					float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dotLN);
					float3 specularReflection = float3(0.0, 0.0, 0.0);
					if (dotLN >= 0.0) {

						float dotHN = dot(halfWayDir, normalDir);
						float dotVN = dot(viewDir, normalDir);
						float dotHTAx = dot(halfWayDir, tangentDir) / _AlphaX;
						float dotHBAy = dot(halfWayDir, binormal) / _AlphaY;

						float sqrtTermdotLN = sqrt(max(0.0, dotLN / dotVN)); //dotLN / dotVN instead of dotLN * dotVN since you multiply with dotLN when doing light computations to check if the light can hit the vertex

						specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * sqrtTermdotLN * exp(-2.0 * (dotHTAx*dotHTAx + dotHBAy*dotHBAy) / (1 + dotHN));
					}

					return float4(ambientLight + diffuseReflection + specularReflection, 1.0);
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
				uniform sampler2D _MainTex;
				uniform float4 _LightColor0;
				uniform float _AlphaX;
				uniform float _AlphaY;

				struct vertIn {
					float4 pos : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
				};

				struct vertOut {
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0;
					float3 normal : TEXCOORD1;
					float4 tex : TEXCOORD2;
					float3 viewDir : TEXCOORD3;
					float3 tangent : TEXCOORD4;
				};

				vertOut vert(vertIn i) {
					vertOut o;
					o.pos = mul(UNITY_MATRIX_MVP, i.pos);
					o.worldPos = mul(unity_ObjectToWorld, i.pos);
					o.tex = i.texcoord;
					o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
					o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos.xyz);
					o.tangent = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0).xyz));
					return o;
				}

				float4 frag(vertOut i) : SV_TARGET{
					float3 normalDir = normalize(i.normal); //Renormalizing in case it isnt a unit length after interpolation
					float3 viewDir = normalize(i.viewDir);
					float3 tangentDir = normalize(i.tangent);
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

					float3 halfWayDir = normalize(lightDir + viewDir);
					float3 binormal = cross(normalDir, tangentDir);
					float dotLN = dot(lightDir, normalDir);

					float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dotLN);
					float3 specularReflection = float3(0.0, 0.0, 0.0);
					if (dotLN >= 0.0) {

						float dotHN = dot(halfWayDir, normalDir);
						float dotVN = dot(viewDir, normalDir);
						float dotHTAx = dot(halfWayDir, tangentDir) / _AlphaX;
						float dotHBAy = dot(halfWayDir, binormal) / _AlphaY;

						float sqrtTermdotLN = sqrt(max(0.0, dotLN / dotVN)); //dotLN / dotVN instead of dotLN * dotVN since you multiply with dotLN when doing light computations to check if the light can hit the vertex

						specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * sqrtTermdotLN * exp(-2.0 * (dotHTAx*dotHTAx + dotHBAy*dotHBAy) / (1 + dotHN));
					}

					return float4(ambientLight + diffuseReflection + specularReflection, 1.0);
				}
			ENDCG
			}
		}
			FallBack "Specular"
	}

