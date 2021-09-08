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

    public static Texture2D Generate(int width, int height, float offsetX, float offsetY, Utils.NoiseType noiseType)
    {
        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[width * height];

        offsetX += 0.01f;
        offsetY += 0.01f;

        float[,] noiseMap = new float[width, height];

        switch (noiseType)
        {
            case Utils.NoiseType.simplex:
                noiseMap = GenerateNoiseMap(width, height, offsetX, offsetY, noise.snoise);
                break;
            case Utils.NoiseType.displacement:
                break;
            case Utils.NoiseType.perlin:
            default:
                noiseMap = GenerateNoiseMap(width, height, offsetX, offsetY, noise.cnoise);
                break;
        }
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                Debug.Log(noiseMap[x, y]);
                colors[x + width * y] = Color.Lerp(Color.white, Color.black, noiseMap[x, y]);
            }
        }
        texture.SetPixels(0, 0, width, height, colors);
        texture.Apply();

        return texture;
    }

    public static float[,] GenerateNoiseMap(int width, int height, float offsetX, float offsetY, Func<float2, float> NoiseFunc)
    {
        float[,] noiseMap = new float[width,height];

        float minNoise = Mathf.Infinity;
        float maxNoise = Mathf.NegativeInfinity;

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                float noiseSample = NoiseFunc(new float2(x + offsetX, y + offsetY));
                if(noiseSample < minNoise)
                {
                    minNoise = noiseSample;
                }
                if(noiseSample > maxNoise)
                {
                    maxNoise = noiseSample;
                }
                noiseMap[x, y] = noiseSample;
            }
        }

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                noiseMap[x, y] = Mathf.InverseLerp(minNoise, maxNoise, noiseMap[x, y]);
            }
        }
        
        return noiseMap;
    }
}
