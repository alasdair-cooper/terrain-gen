using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TerrainGeneration : MonoBehaviour
{
    public Utils.NoiseType noiseType;

    public int width = 10;
    public int height = 10;

    public int widthOffset = 0;
    public int heightOffset = 0;

    [Min(0.01f)]
    public float noiseScale = 1;
    [Min(0.01f)]
    public float verticalScale = 1;

    [Min(1)]
    public int octaves = 5;

    [Range(0, 100)]
    public float lacunarity;
    [Range(0, 1)]
    public float persistence;
    
    public GameObject texturePlane;

    // Start is called before the first frame update
    void Start()
    {
        Generate();
    }

    // Update is called once per frame
    void Update()
    {
        Generate();
    }

    void Generate()
    {
        MeshFilter meshFilter = texturePlane.GetComponent<MeshFilter>();
        MeshCollider meshCollider = texturePlane.GetComponent<MeshCollider>();
        MeshRenderer meshRenderer = texturePlane.GetComponent<MeshRenderer>();

        NoiseMapInfo mapInfo = new NoiseMapInfo(width, height, widthOffset, heightOffset, noiseScale, octaves, lacunarity, persistence);

        meshFilter.sharedMesh = MeshGeneration.GeneratePlane(width, height);
        meshCollider.sharedMesh = meshFilter.sharedMesh;

        float[,] noiseMap = NoiseGeneration.Generate(mapInfo, noiseType);
        meshRenderer.sharedMaterial.mainTexture = TextureGeneration.Generate(mapInfo, noiseMap, noiseType);

        meshFilter.sharedMesh = MeshGeneration.ApplyHeightmap(meshFilter.sharedMesh, noiseMap, verticalScale);
        //meshCollider.sharedMesh = meshFilter.sharedMesh;
    }

    
}
