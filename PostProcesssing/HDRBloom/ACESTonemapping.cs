using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class ACESTonemapping : MonoBehaviour
{
    public Material material;

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
        Graphics.Blit(source, destination, material, 0);
    }
}
