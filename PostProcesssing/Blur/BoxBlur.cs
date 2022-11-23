using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class BoxBlur : MonoBehaviour
{
    public Material material;
    [Range(0, 10)]
    public int _Iteration = 4;
    [Range(0, 15)]
    public float _BlurRadius = 5.0f;
    public float _DownSample = 2.0f;

    private void Start()
    {
        if(material == null || material.shader == null
            || material.shader.isSupported == false)
        {
            enabled = false;
            return;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int width = (int)(source.width / _DownSample);
        int height = (int)(source.height / _DownSample);
        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);

        Graphics.Blit(source, RT1);
        material.SetVector("_BlurOffset", new Vector4(_BlurRadius / width, _BlurRadius / height, 0, 0));
        for(int i=0; i<_Iteration; i++)
        {
            Graphics.Blit(RT1, RT2, material, 0);
            Graphics.Blit(RT2, RT1, material, 0);
        }      
        Graphics.Blit(RT1, destination);

        //release
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
