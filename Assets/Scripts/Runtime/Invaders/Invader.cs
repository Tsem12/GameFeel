using System;
using UnityEngine;
using UnityEngine.Events;

public class Invader : MonoBehaviour
{
    [SerializeField] private Bullet bulletPrefab = null;
    [SerializeField] private Transform shootAt = null;
    [SerializeField] private string collideWithTag = "Player";
    [SerializeField] private Collider2D _collider;
    [SerializeField] private Rigidbody2D _rb;
    [SerializeField] private int maxLife;
    private int currentLife;
    private bool _isDead;

    [SerializeField] public UnityEvent OnSpawn;
    [SerializeField] public UnityEvent OnDeath;
    [SerializeField] public UnityEvent OnSoot;
    [SerializeField] public UnityEvent OnLineChanged;
    [SerializeField] public UnityEvent OnTakeDamage;

    public static Action<Invader> OnDeathAction;

    public Vector2Int GridIndex { get; private set; }

    public void Start()
    {
        currentLife = maxLife;
        OnSpawn?.Invoke();
    }

    public void Initialize(Vector2Int gridIndex)
    {
        this.GridIndex = gridIndex;
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.gameObject.tag != collideWithTag) { return; }
        Destroy(collision.gameObject);

        if (--currentLife <= 0)
        {
            _collider.enabled = false;
            transform.parent = null;
            _rb.bodyType = RigidbodyType2D.Dynamic;
            OnDeathAction?.Invoke(this);
            OnDeath?.Invoke(); //gamefeel
            _isDead = true;
        }
        else
        {
            OnTakeDamage?.Invoke();    
        }
    }

    public void OnMoveDown()
    {
        if(_isDead)
            return;
        OnLineChanged?.Invoke();
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
