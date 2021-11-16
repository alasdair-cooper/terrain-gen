using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseMapInfo
{
    private float _widthOffset;
    private float _heightOffset;

    public int Width { get; set; }
    public int Height { get; set; }

    public float WidthOffset { get => _widthOffset; set => _widthOffset = value + 0.1f; }
    public float HeightOffset { get => _heightOffset; set => _heightOffset = value + 0.1f; }

    public float NoiseScale { get; set; }
    public float VerticalScale { get; set; }

    public int Octaves { get; set; }
    public float Lacunarity { get; set; }
    public float Persistence { get; set; }

    public NoiseMapInfo(int width, int height, float widthOffset, float heightOffset, float noiseScale, int octaves, float lacunarity, float persistence)
    {
        Width = width;
        Height = height;

        WidthOffset = widthOffset;
        HeightOffset = heightOffset;

        NoiseScale = noiseScale;
        
        Octaves = octaves;

        Lacunarity = lacunarity;
        Persistence = persistence;
    }
}