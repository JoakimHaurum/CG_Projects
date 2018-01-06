Shader "Hidden/Night_Vision"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_VignetteTex("Vignette", 2D) = "white" {}
		_ScanlineTex("Scanline", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_NoiseSpeed("Noise speed", Vector) = (100, 100,0,0)
		_ScanlineTiling("Scanline tiling", Float) = 4.0
		_NightVisionColor("Night vision color", Color) = (1,1,1,1)
		_Contrast("Contrast", Range(0,4)) = 2
		_Brightness("Brightness", Range(0,1)) = 1
		_RandomValue("Rand value", Float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"			
			uniform sampler2D _MainTex;
			uniform sampler2D _VignetteTex;
			uniform sampler2D _ScanlineTex;
			uniform sampler2D _NoiseTex;
			uniform float2 _NoiseSpeed;
			uniform float _ScanlineTiling;
			uniform float _Contrast;
			uniform float _Brightness; 
			uniform float _RandomValue;
			uniform float4 _NightVisionColor;

			struct vertIn{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct vertOut{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			vertOut vert (vertIn i)
			{
				vertOut o;
				o.vertex = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.uv;
				return o;
			}

			float4 frag (vertOut i) : SV_Target
			{
				float4 main = tex2D(_MainTex, i.uv);
				float4 vig = tex2D(_VignetteTex, i.uv);
				float4 scan = tex2D(_ScanlineTex, i.uv*_ScanlineTiling);
				float4 noise = tex2D(_NoiseTex, float2(i.uv.x + (_RandomValue * _Time.x * _NoiseSpeed.x), i.uv.y + (_RandomValue * _CosTime.y * _NoiseSpeed.y)));

				float luminance = dot(float3(0.299, 0.587, 0.114), main.rgb); //Convet to YIQ color space
				luminance += _Brightness;

				float4 color = luminance * 2 + _NightVisionColor;
				color = pow(color, _Contrast) * vig * scan * noise;
				return color;
			}
			ENDCG
		}
	}
}
