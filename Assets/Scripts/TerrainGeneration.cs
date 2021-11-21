using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TerrainGeneration : MonoBehaviour
{
    public Utils.RenderMode renderMode;
    public Utils.NoiseType noiseType;
    
    [Min(2)]
    public int width = 10;
    [Min(2)]
    public int height = 10;

    public int widthOffset = 0;
    public int heightOffset = 0;

    [Min(0.01f)]
    public float noiseScale = 1;
    [Min(0.01f)]
    public float verticalScale = 1;

    [Range(1, 5)]
    public int octaves = 5;

    [Range(0, 100)]
    public float lacunarity;
    [Range(0, 1)]
    public float persistence;
    
    public GameObject terrainObject;

    // Start is called before the first frame update
    void Start()
    {
        Generate();
    }

    // Update is called once per frame
    void Update()
    {
        Generate();

        MeshRenderer meshRenderer = terrainObject.GetComponent<MeshRenderer>();
        Material material = meshRenderer.material;

        // Put the properties in a noise map info object first as it modifies them in important ways
        NoiseMapInfo mapInfo = new NoiseMapInfo(width, height, widthOffset, heightOffset, noiseScale, verticalScale, octaves, lacunarity, persistence);

        material.SetInteger("_NoiseType", ((int)noiseType));
        material.SetFloat("_WidthOffset", mapInfo.WidthOffset);
        material.SetFloat("_HeightOffset", mapInfo.HeightOffset);
        material.SetFloat("_NoiseScale", mapInfo.NoiseScale);
        material.SetFloat("_VerticalScale", mapInfo.VerticalScale);
        material.SetFloat("_Octaves", mapInfo.Octaves);
        material.SetFloat("_Lacunarity", mapInfo.Lacunarity);
        material.SetFloat("_Persistence", mapInfo.Persistence);

        if(renderMode == Utils.RenderMode.CPU)
        {
            material.SetInteger("_Enabled", 0);
        }
        else
        {
            material.SetInteger("_Enabled", 1);
        }
    }

    void Generate()
    {
        MeshFilter meshFilter = terrainObject.GetComponent<MeshFilter>();
        //MeshCollider meshCollider = terrainObject.GetComponent<MeshCollider>();
        MeshRenderer meshRenderer = terrainObject.GetComponent<MeshRenderer>();

        // Create an object to store all the info about the heightmap and the noise generation
        NoiseMapInfo mapInfo = new NoiseMapInfo(width, height, widthOffset, heightOffset, noiseScale, verticalScale, octaves, lacunarity, persistence);

        // Generate a flat plane
        meshFilter.sharedMesh = MeshGeneration.GeneratePlane(width, height);
        //meshCollider.sharedMesh = meshFilter.sharedMesh;

        if (renderMode == Utils.RenderMode.CPU)
        {
            // Create the noise map (heightmap)
            float[,] noiseMap = NoiseGeneration.Generate(mapInfo, noiseType);
            meshRenderer.sharedMaterial.mainTexture = TextureGeneration.Generate(mapInfo, noiseMap);

            // Apply the noise map to the flat plane to produce a distorted mesh 
            meshFilter.sharedMesh = MeshGeneration.ApplyHeightmap(meshFilter.sharedMesh, noiseMap, verticalScale);
            //meshCollider.sharedMesh = meshFilter.sharedMesh;
        }
    }

    
}
