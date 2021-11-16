using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureGeneration
{
    /// <summary>
    /// Generates a flat texture.
    /// </summary>
    /// <param name="width">Width of the texture</param>
    /// <param name="height">Height of the texture</param>
    /// <returns>The texture generated</returns>
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

    /// <summary>
    /// Generates a texture based on an input heightmap.
    /// </summary>
    /// <param name="mapInfo">Information about the dimensions of the heightmap</param>
    /// <param name="noiseMap">The heightmap</param>
    /// <returns>The texture generated</returns>
    public static Texture2D Generate(NoiseMapInfo mapInfo, float[,] noiseMap)
    {
        int width = mapInfo.Width;
        int height = mapInfo.Height;

        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[width * height];
                        
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                // Light peaks, dark valleys
                colors[x + width * y] = Color.Lerp(Color.black, Color.white, noiseMap[x, y]);
            }
        }
        texture.SetPixels(0, 0, width, height, colors);
        texture.Apply();

        return texture;
    }
}
