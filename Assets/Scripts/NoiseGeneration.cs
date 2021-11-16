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

        //for (int y = 0; y < mapInfo.Height; y++)
        //{
        //    for (int x = 0; x < mapInfo.Width; x++)
        //    {
        //        float noiseSample = NoiseFunc(new float2((x / mapInfo.NoiseScale) + mapInfo.WidthOffset, (y / mapInfo.NoiseScale) + mapInfo.HeightOffset));

        //        if (noiseSample < minNoise)
        //        {
        //            minNoise = noiseSample;
        //        }
        //        if (noiseSample > maxNoise)
        //        {
        //            maxNoise = noiseSample;
        //        }
        //        noiseMap[x, y] = noiseSample;
        //    }
        //}

        //for (int y = 0; y < mapInfo.Height; y++)
        //{
        //    for (int x = 0; x < mapInfo.Width; x++)
        //    {
        //        noiseMap[x, y] = Mathf.InverseLerp(minNoise, maxNoise, noiseMap[x, y]);
        //    }
        //}

        for (int z = 0; z < mapInfo.Height; z++)
        {
            for (int x = 0; x < mapInfo.Width; x++)
            {
                float frequency = 1;
                float amplitude = 1;
                float noiseHeight = 0;
                for (int i = 0; i < mapInfo.Octaves; i++)
                {
                    float xValue = (x / mapInfo.NoiseScale) * frequency;
                    float zValue = (z / mapInfo.NoiseScale) * frequency;

                    float noisevalue = (Mathf.PerlinNoise(xValue + mapInfo.WidthOffset, zValue + mapInfo.HeightOffset) * 2) - 1;
                    noiseHeight += noisevalue * amplitude;
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