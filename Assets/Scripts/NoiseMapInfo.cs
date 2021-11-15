using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseMapInfo
{
    private float _widthOffset;
    private float _heightOffset;

    private float _noiseScale;
    private float _verticalScale;

    public int Width { get; set; }
    public int Height { get; set; }

    public float WidthOffset { get => _widthOffset; set => _widthOffset = value + 0.1f; }
    public float HeightOffset { get => _heightOffset; set => _heightOffset = value + 0.1f; }

    public float NoiseScale 
    { 
        get => _noiseScale; 
        set 
        { 
            if (value <= 0)
            {
                _noiseScale = 0.01f;
            }
            else
            {
                _noiseScale = value;
            }
        } 
    }

    public float VerticalScale
    {
        get => _verticalScale;
        set
        {
            if (value <= 0)
            {
                _verticalScale = 0.01f;
            }
            else
            {
                _verticalScale = value;
            }
        }
    }

    public NoiseMapInfo(int width, int height, float widthOffset, float heightOffset, float noiseScale)
    {
        Width = width;
        Height = height;

        WidthOffset = widthOffset;
        HeightOffset = heightOffset;

        NoiseScale = noiseScale;
    }
}