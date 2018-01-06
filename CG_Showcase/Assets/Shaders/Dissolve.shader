Shader "Custom/Dissolve" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BurnTex ("Burn map", 2D) = "white" {}
		_BurnGradient ("Burn Gradient", 2D) = "white" {}
		_DissolveValue ("Dissolve Value", Range(0,1)) = 0.0
	}
	SubShader {
		Tags{"Queue" = "Transparent"}
		Pass{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _Color;
			uniform float _DissolveValue;
			uniform sampler2D _MainTex;
			uniform sampler2D _BurnTex;
			uniform sampler2D _BurnGradient;

			struct vertIn{
				float4 pos : POSITION;
				float4 tex : TEXCOORD0;
			};

			struct vertOut{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};

			vertOut vert(vertIn i){
				vertOut o;
				o.pos = mul(UNITY_MATRIX_MVP, i.pos);
				o.tex = i.tex;
				return o;
			}

			float4 frag(vertOut i) : SV_TARGET{
				float burnValue = tex2D(_BurnTex, i.tex).x;
				float texVal = (2.0 * (1.0-_DissolveValue) + burnValue) - 1.0;
				float4 burnCol = tex2D(_BurnGradient, float2(texVal, 0.5));
				float4 texCol = tex2D(_MainTex, i.tex);

				return texCol * burnCol;
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
