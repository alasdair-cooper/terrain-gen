using System.Collections;
using UnityEngine;
using Unity.Mathematics;
using System;

public class NoiseGeneration
{
    public static float[,] Generate(NoiseMapInfo mapInfo, Utils.NoiseType noiseType)
    {
        float[,] noiseMap = new float[mapInfo.Width, mapInfo.Height];

        switch (noiseType)
        {
            case Utils.NoiseType.simplex:
                GenerateNoiseMap(mapInfo, noise.snoise, out noiseMap);
                break;
            case Utils.NoiseType.displacement:
                break;
            case Utils.NoiseType.perlin:
            default:
                GenerateNoiseMap(mapInfo, noise.cnoise, out noiseMap);
                break;
        }

        return noiseMap;
    }

    static void GenerateNoiseMap(NoiseMapInfo mapInfo, Func<float2, float> NoiseFunc, out float[,] noiseMap)
    {
        noiseMap = new float[mapInfo.Width, mapInfo.Height];

        float minNoise = Mathf.Infinity;
        float maxNoise = Mathf.NegativeInfinity;

        for (int z = 0; z < mapInfo.Height; z++)
        {
            for (int x = 0; x < mapInfo.Width; x++)
            {
                // Factors to modify the noise by
                float frequency = 1;
                float amplitude = 1;

                // Noise value for this point (x, z)
                float noiseHeight = 0;

                for (int i = 0; i < mapInfo.Octaves; i++)
                {
                    float xValue = (x / mapInfo.NoiseScale) * frequency;
                    float zValue = (z / mapInfo.NoiseScale) * frequency;

                    // Calculate the noise value at the location using the input noise algorithm, and normalise
                    float noiseSample = (NoiseFunc(new float2(xValue + mapInfo.WidthOffset, zValue + mapInfo.HeightOffset)) * 2) - 1;

                    noiseHeight += noiseSample * amplitude;

                    frequency *= mapInfo.Lacunarity;
                    amplitude *= mapInfo.Persistence;
                }
                noiseMap[x, z] = noiseHeight;

                if (noiseHeight > maxNoise)
                {
                    maxNoise = noiseHeight;
                }
                else if (noiseHeight < minNoise)
                {
                    minNoise = noiseHeight;
                }
            }
        }

        for (int y = 0; y < mapInfo.Height; y++)
        {
            for (int x = 0; x < mapInfo.Width; x++)
            {
                noiseMap[x, y] = Mathf.InverseLerp(minNoise, maxNoise, noiseMap[x, y]);
            }
        }
    }
}