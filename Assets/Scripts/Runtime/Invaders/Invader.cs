using System;
using UnityEngine;
using UnityEngine.Events;

public class Invader : MonoBehaviour
{
    [SerializeField] private Bullet bulletPrefab = null;
    [SerializeField] private Transform shootAt = null;
    [SerializeField] private string collideWithTag = "Player";
    [SerializeField] private int maxLife;
    private int currentLife;

    [SerializeField] public UnityEvent OnDeath;
    [SerializeField] public UnityEvent OnSoot;
    [SerializeField] public UnityEvent OnLineChanged;
    [SerializeField] public UnityEvent OnTakeDamage;


    public static Action<Invader> onDestroy;

    public Vector2Int GridIndex { get; private set; }

    public void Start()
    {
        currentLife = maxLife;
    }

    public void Initialize(Vector2Int gridIndex)
    {
        this.GridIndex = gridIndex;
    }

    public void OnDestroy()
    {
        onDestroy?.Invoke(this);
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.gameObject.tag != collideWithTag) { return; }
        Destroy(collision.gameObject);

        if (--currentLife <= 0)
        {
            Debug.Log("Deadmdrrr");
            OnDeath?.Invoke(); //gamefeel
        }
        else
        {
            OnTakeDamage?.Invoke();    
        }
    }

    public void Shoot()
    {
        Instantiate(bulletPrefab, shootAt.position, Quaternion.identity);
        OnSoot?.Invoke();
    }

    public void ClearInvader()
    {
        Destroy(gameObject);
    }
}
