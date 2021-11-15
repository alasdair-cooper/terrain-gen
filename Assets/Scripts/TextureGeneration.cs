using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using static Unity.Mathematics.noise;
using Unity.Mathematics;

public class TextureGeneration
{
    public static Texture2D Generate(int width, int height)
    {
        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[width * height];
        for (int i = 0; i < colors.Length; i++)
        {
            colors[i] = Color.cyan;
        }
        texture.SetPixels(0, 0, width, height, colors);
        texture.Apply();

        return texture;
    }

    public static Texture2D Generate(NoiseMapInfo mapInfo, float[,] noiseMap, Utils.NoiseType noiseType)
    {
        int width = mapInfo.Width;
        int height = mapInfo.Height;

        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[width * height];
                        
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                colors[x + width * y] = Color.Lerp(Color.white, Color.black, noiseMap[x, y]);
            }
        }
        texture.SetPixels(0, 0, width, height, colors);
        texture.Apply();

        return texture;
    }
}
