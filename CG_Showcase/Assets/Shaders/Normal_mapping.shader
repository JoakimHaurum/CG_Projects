Shader "Custom/Normal_mapping" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_SpecColor("Specular material color", Color) = (1,1,1,1)
		_Shininess("Shininess of specular component", Float) = 1.0
		_MainTex("Main texture", 2D) = "white" {}
		_BumpMap("Bump/normal map", 2D) = "bump" {}
	}
			SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"

					uniform float4 _LightColor0;
					uniform float4 _Color;
					uniform float4 _SpecColor;
					uniform float _Shininess;
					uniform sampler2D _BumpMap;
					uniform float4 _BumpMap_ST;
					uniform sampler2D _MainTex;

					struct vertIn {
						float4 pos : POSITION;
						float4 texcoord : TEXCOORD0;
						float3 normal : NORMAL;
						float4 tangent : TANGENT;
					};
					struct vertOut {
						float4 pos : SV_POSITION;
						float4 worldPos : TEXCOORD0;
						float4 tex : TEXCOORD1;
						float3 normalWorld : TEXCOORD2;
						float3 tangentWorld : TEXCOORD3;
						float3 binormalWorld : TEXCOORD4;
					};

					vertOut vert(vertIn i) {
						vertOut o;
						//Calculate world representation of the tangent, normal and binormal needed for converting the bump map to world coordinates
						o.tangentWorld = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0)).xyz);
						o.normalWorld = normalize(mul(float4(i.normal, 0.0),unity_WorldToObject).xyz);
						o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld)*i.tangent.w); //tangent.w is only needed in Unity. provides a scaling factor for accurately calculating the binormal vector

						o.worldPos = mul(unity_ObjectToWorld, i.pos);
						o.tex = i.texcoord;
						o.pos = mul(UNITY_MATRIX_MVP, i.pos);
						return o;
					}

					float4 frag(vertOut i) : SV_TARGET{
						//Normal map part
						float3 normalW = normalize(i.normalWorld);
						float3 tangentW = normalize(i.tangentWorld);
						float3 binormalW = normalize(i.binormalWorld);

						float4 texNormal = tex2D(_BumpMap, _BumpMap_ST.xy * i.tex.xy + _BumpMap_ST.zw); //Stored as 2-component encoded local surface coordiantes
						float3 texLocal = float3(2.0 * texNormal.a - 1.0, 2.0 * texNormal.g - 1.0, 0.0);
						texLocal.z = sqrt(1 - texLocal.x*texLocal.x + texLocal.y*texLocal.y);

						float3x3 texLocal2WorldT = float3x3(tangentW, binormalW, normalW);
						float3 texNormalDir = normalize(mul(texLocal, texLocal2WorldT));

						//Phong shader part
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
						float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dot(texNormalDir, lightDir));
						float3 specularReflection = float3(0.0, 0.0, 0.0);
						if (dot(texNormalDir, lightDir) >= 0.0)
							specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDir, texNormalDir), viewDir)), _Shininess);

						return float4(ambientLight + diffuseReflection + specularReflection, 1.0);
					}
				ENDCG
				}

			Pass{
					Tags{ "LightMode" = "ForwardAdd" }
					Blend One One
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"

					uniform float4 _LightColor0;
					uniform float4 _Color;
					uniform float4 _SpecColor;
					uniform float _Shininess;
					uniform sampler2D _BumpMap;
					uniform float4 _BumpMap_ST;
					uniform sampler2D _MainTex;

					struct vertIn {
						float4 pos : POSITION;
						float4 texcoord : TEXCOORD0;
						float3 normal : NORMAL;
						float4 tangent : TANGENT;
					};
					struct vertOut {
						float4 pos : SV_POSITION;
						float4 worldPos : TEXCOORD0;
						float4 tex : TEXCOORD1;
						float3 normalWorld : TEXCOORD2;
						float3 tangentWorld : TEXCOORD3;
						float3 binormalWorld : TEXCOORD4;
					};

					vertOut vert(vertIn i) {
						vertOut o;
						//Calculate world representation of the tangent, normal and binormal needed for converting the bump map to world coordinates
						o.tangentWorld = normalize(mul(unity_ObjectToWorld, float4(i.tangent.xyz, 0.0)).xyz);
						o.normalWorld = normalize(mul(float4(i.normal, 0.0),unity_WorldToObject).xyz);
						o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld)*i.tangent.w); //tangent.w is only needed in Unity. provides a scaling factor for accurately calculating the binormal vector

						o.worldPos = mul(unity_ObjectToWorld, i.pos);
						o.tex = i.texcoord;
						o.pos = mul(UNITY_MATRIX_MVP, i.pos);
						return o;
					}

					float4 frag(vertOut i) : SV_TARGET{
					//Normal map part
					float3 normalW = normalize(i.normalWorld);
					float3 tangentW = normalize(i.tangentWorld);
					float3 binormalW = normalize(i.binormalWorld);

					float4 texNormal = tex2D(_BumpMap, _BumpMap_ST.xy * i.tex.xy + _BumpMap_ST.zw); //Stored as 2-component encoded local surface coordiantes
					float3 texLocal = float3(2.0 * texNormal.a - 1.0, 2.0 * texNormal.g - 1.0, 0.0);
					texLocal.z = sqrt(1 - texLocal.x*texLocal.x + texLocal.y*texLocal.y);

					float3x3 texLocal2WorldT = float3x3(tangentW, binormalW, normalW);
					float3 texNormalDir = normalize(mul(texLocal, texLocal2WorldT));

					//Phong shader part
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

					float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * max(0.0, dot(texNormalDir, lightDir));
					float3 specularReflection = float3(0.0, 0.0, 0.0);
					if (dot(texNormalDir, lightDir) >= 0.0)
						specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDir, texNormalDir), viewDir)), _Shininess);

					return float4(diffuseReflection + specularReflection, 1.0);
					}
				ENDCG
			}
		}
	FallBack "Diffuse"
}
