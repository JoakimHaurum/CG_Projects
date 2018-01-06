Shader "Custom/Oren-Nayer" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Sigma ("Stand deviation of Gaussian distribution)", Float) = 0.1
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader{
			Pass{
				Tags{ "LightMode" = "ForwardBase" }
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				uniform float4 _Color;
				uniform sampler2D _MainTex;
				uniform float _Sigma;
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
					o.normal = normalize(mul(float4(i.normal,0.0), unity_WorldToObject).xyz);
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

					float3 oren_nayer_term = float3(0.0, 0.0, 0.0);
					float lightDotNormal = dot(lightDir, normalDir);
					if (lightDotNormal >= 0.0) {	//If light is on the correct side of the model
						float sigma_sqr = _Sigma * _Sigma;
						float A = 1 - 0.5*sigma_sqr / (sigma_sqr + 0.33);	//Oren-nayer states in their paper that the 0.3 can be replaced with 0.57 to compensate for the lack of the interreflection term
						float B = 0.45*sigma_sqr / (sigma_sqr + 0.09);

						float viewDotNormal = dot(viewDir, normalDir);
						float theta_r = acos(viewDotNormal);
						float theta_i = acos(lightDotNormal);
						float alpha = max(theta_i, theta_r);
						float beta = min(theta_i, theta_r);

						//The term max(0.0,cos(phi_i-phi_r)) describes the aximuth angle between the two light and view vector around the normal vector
						//To calculate this, the two vectors are projected onto the plane described by the normal vector, normalized, and the dot product is taken to get the angle between them
						float3 viewDirPlane = normalize(viewDir - viewDotNormal*normalDir);
						float3 lightDirPlane = normalize(lightDir - lightDotNormal*normalDir);

						oren_nayer_term = lightDotNormal * (A + B*sin(alpha)*tan(beta)*max(0.0, dot(viewDirPlane, lightDirPlane)));

					}
					float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
					float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * oren_nayer_term;

					return float4(ambientLight + diffuseReflection, 1.0);

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
			uniform float4 _Color;
			uniform sampler2D _MainTex;
			uniform float _Sigma;
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
				o.normal = normalize(mul(float4(i.normal,0.0), unity_WorldToObject).xyz);
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

				float3 oren_nayer_term = float3(0.0, 0.0, 0.0);
				float lightDotNormal = dot(lightDir, normalDir);
				if (lightDotNormal >= 0.0) {	//If light is on the correct side of the model
					float sigma_sqr = _Sigma * _Sigma;
					float A = 1 - 0.5*sigma_sqr / (sigma_sqr + 0.33);	//Oren-nayer states in their paper that the 0.33 can be replaced with 0.57 to compensate for the lack of the interreflection term
					float B = 0.45*sigma_sqr / (sigma_sqr + 0.09);

					float viewDotNormal = dot(viewDir, normalDir);
					float theta_r = acos(viewDotNormal);
					float theta_i = acos(lightDotNormal);
					float alpha = max(theta_i, theta_r);
					float beta = min(theta_i, theta_r);

					//The term max(0.0,cos(phi_i-phi_r)) describes the aximuth angle between the two light and view vector around the normal vector
					//To calculate this, the two vectors are projected onto the plane described by the normal vector, normalized, and the dot product is taken to get the angle between them
					float3 viewDirPlane = normalize(viewDir - viewDotNormal*normalDir);
					float3 lightDirPlane = normalize(lightDir - lightDotNormal*normalDir);

					oren_nayer_term = lightDotNormal * (A + B*sin(alpha)*tan(beta)*max(0.0, dot(viewDirPlane, lightDirPlane)));
				}

				float3 diffuseReflection = attenuation * textureColor.rgb * _LightColor0.rgb * _Color.rgb * oren_nayer_term;

				return float4(diffuseReflection, 1.0);

			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
