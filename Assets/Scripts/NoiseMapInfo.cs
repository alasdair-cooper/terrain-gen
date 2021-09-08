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

    public float Scale { get; set; }

    public NoiseMapInfo(int width, int height, float widthOffset, float heightOffset, float scale)
    {
        Width = width;
        Height = height;

        WidthOffset = widthOffset;
        HeightOffset = heightOffset;

        Scale = scale;
    }
}