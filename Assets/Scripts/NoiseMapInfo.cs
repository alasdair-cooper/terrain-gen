using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseMapInfo
{
    private float _widthOffset;
    private float _heightOffset;

    public int Width { get; set; }
    public int Height { get; set; }

    public float WidthOffset { get; set; }
    public float HeightOffset { get; set; }

    public float NoiseScale { get; set; }
    public float VerticalScale { get; set; }

    public int Octaves { get; set; }
    public float Lacunarity { get; set; }
    public float Persistence { get; set; }

    public NoiseMapInfo(int width, int height, float widthOffset, float heightOffset, float noiseScale, float verticalScale, int octaves, float lacunarity, float persistence)
    {
        Width = width + 1;
        Height = height + 1;

        WidthOffset = widthOffset;
        HeightOffset = heightOffset;

        NoiseScale = noiseScale;
        VerticalScale = verticalScale;
        
        Octaves = octaves;

        Lacunarity = lacunarity;
        Persistence = persistence;
    }
}