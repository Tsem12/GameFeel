using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Multipliers", menuName = "ScriptableObjects/Multipliers", order = 1)]
public class Multipliers : ScriptableObject
{
    [System.Serializable]
    public struct Multiplier
    {
        public int cumulativeScore;
        public float multiplier;
    }

    public List<Multiplier> multipliers;
}
