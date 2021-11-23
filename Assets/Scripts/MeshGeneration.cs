using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGeneration
{
    static public Mesh GeneratePlane(int width, int height)
    {
        Mesh mesh = new Mesh();
        mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;

        Vector3[] vertices = new Vector3[width * height];
        int[] triangles = new int[(width - 1) * (height - 1) * 6];
        Vector2[] uvs = new Vector2[width * height];

        int vertexIndex = 0;
        int triangleIndex = 0;

        for (int z = 0; z < height; z++)
        {
            for (int x = 0; x < width; x++)
            {
                // Ensures the transform is at the center of the mesh instead of the corner
                //vertices[vertexIndex] = new Vector3(x - (0.5f * width), 0, z - (0.5f * height));
                vertices[vertexIndex] = new Vector3(x, 0, z);

                // Creates triangle pairs for each vertex apart from those at the end of a row and/or column
                // Triangles are the index of each vertex of the triangles corners
                if (x < width - 1 && z < height - 1)
                {
                    // First triangle
                    triangles[triangleIndex] = vertexIndex + width;
                    triangles[triangleIndex + 1] = vertexIndex + width + 1;
                    triangles[triangleIndex + 2] = vertexIndex;
                    // Second triangle
                    triangles[triangleIndex + 3] = vertexIndex + 1;
                    triangles[triangleIndex + 4] = vertexIndex;
                    triangles[triangleIndex + 5] = vertexIndex + width + 1;

                    triangleIndex += 6;
                }
                uvs[vertexIndex] = new Vector2(x / (float)width, z / (float)height);
                vertexIndex++;
            }
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;

        return mesh;
    }

    static public Mesh ApplyHeightmap(Mesh mesh, float[,] noiseMap, float scale)
    {
        int height = noiseMap.GetLength(1);
        int width = noiseMap.GetLength(0);

        Vector3[] vertices = new Vector3[width * height];

        int vertexIndex = 0;

        for (int z = 0; z < height; z++)
        {
            for (int x = 0; x < width; x++)
            {
                vertices[vertexIndex] = new Vector3(x, noiseMap[x, z] * scale, z);
                vertexIndex++;
            }
        }

        mesh.vertices = vertices;
        return mesh;
    }
}
