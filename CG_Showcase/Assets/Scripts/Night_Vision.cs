using UnityEngine;
using System.Collections;

public class Night_Vision : MonoBehaviour {

    private Shader _shader;
    private Shader shader
    {
        get { return _shader != null ? _shader : (_shader = Shader.Find("Hidden/Night_Vision")); }
    }

    private Material _material;
    private Material material
    {
        get
        {
            if (_material == null)
            {
                _material = new Material(shader);
                _material.hideFlags = HideFlags.HideAndDontSave;
            }
            return _material;
        }
    }

	public float contrast = 2.0f;
	public float brightness = 1.0f;
	public float scanLineTiling = 4.0f;

	public Vector2 noiseSpeed = new Vector2(100.0f, 100.0f);
    public Color NV_Color = Color.white;

    public Texture2D Vignette;
    public Texture2D Scanline;
    public Texture2D Noise;

	private float randomValue = 0.0f;

	void Update(){
		contrast = Mathf.Clamp (contrast, 0.0f, 4.0f);
		brightness = Mathf.Clamp (brightness, 0.0f, 2.0f);
		randomValue = Random.Range (-1.0f, 1.0f);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest){
		if (shader != null) {
			material.SetFloat ("_Contrast", contrast);
			material.SetFloat ("_Brightness", brightness);
			material.SetFloat ("_RandomValue", randomValue);
			material.SetColor ("_NightVisionColor", NV_Color);

			if (Vignette)
				material.SetTexture ("_VignetteTex", Vignette);
			if (Scanline) {
				material.SetTexture ("_ScanlineTex", Scanline);
				material.SetFloat ("_ScanlineTiling", scanLineTiling);
			}
			if (Noise) {
				material.SetTexture ("_NoiseTex", Noise);
				material.SetVector ("_NoiseSpeed", noiseSpeed);
			}
				
			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit (src, dest);
		}
	}
}
