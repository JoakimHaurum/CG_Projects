Shader "Custom/Silhouette_Enhancement" {
	Properties{
		_Color("Color", Color) = (1,1,1,0.5)
		_Thickness("Controls silhouette thickness", Float) = 1
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
		SubShader{
			Tags { "Queue" = "Transparent" }
			Pass{
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				uniform float4 _Color;
				uniform float _Thickness;
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;

			struct vertIn {
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float4 tex : TEXCOORD0;
			};

			struct vertOut {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;

			};

			vertOut vert(vertIn i) {
				vertOut o;
				o.pos = mul(UNITY_MATRIX_MVP, i.pos);
				o.normal = normalize(mul(float4(i.normal, 1.0), unity_WorldToObject));
				o.tex = i.tex;
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, i.pos).xyz);
				return o;
			}

			float4 frag(vertOut i) : SV_TARGET{
				float3 normalDir = normalize(i.normal);
				float3 viewDir = normalize(i.viewDir);


				float opacity = min(1.0, _Color.a / (abs(pow(dot(normalDir, viewDir), _Thickness))));
				float4 texCol = tex2D(_MainTex, _MainTex_ST.xy*i.tex.xy + _MainTex_ST.zw);
				return float4(_Color.rgb * texCol.rgb, opacity);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
