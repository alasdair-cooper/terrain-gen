using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainGeneration : MonoBehaviour
{
    public Utils.NoiseType noiseType;

    public int width = 10;
    public int height = 10;

    public int widthOffset = 0;
    public int heightOffset = 0;

    public GameObject texturePlane;

    // Start is called before the first frame update
    void Start()
    {
        Generate();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void Generate()
    {
        MeshFilter meshFilter = texturePlane.GetComponent<MeshFilter>();
        MeshCollider meshCollider = texturePlane.GetComponent<MeshCollider>();
        MeshRenderer meshRenderer = texturePlane.GetComponent<MeshRenderer>();

        meshFilter.mesh = MeshGeneration.Generate(width, height);
        meshCollider.sharedMesh = meshFilter.mesh;

        meshRenderer.sharedMaterial.mainTexture = TextureGeneration.Generate(width, height, widthOffset, heightOffset, noiseType);
    }

    
}
