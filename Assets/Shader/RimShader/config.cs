using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class Monster
{
    public int ID;
    public int Name;
    public int Level;
    public GameObject Obj;
}

[System.Serializable]
public class Monsterconfig : ScriptableObject
{
    public List<Monster> monsterConfig = new List<Monster>();
}
