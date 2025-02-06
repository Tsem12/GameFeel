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
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Invader) == GameManager.GAMEFEEL_ACTIVATION.Invader)
        {
            OnSpawn?.Invoke();
        }
    }

    public void Initialize(Vector2Int gridIndex)
    {
        this.GridIndex = gridIndex;
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if(!collision.gameObject.CompareTag(collideWithTag)) { return; }
        Destroy(collision.gameObject);

        if (--currentLife <= 0)
        {
            _collider.enabled = false;
            transform.parent = null;
            _rb.bodyType = RigidbodyType2D.Dynamic;
            OnDeathAction?.Invoke(this);
            if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Invader) == GameManager.GAMEFEEL_ACTIVATION.Invader)
            {
                OnDeath?.Invoke(); //gamefeel
            }
            else
            {
                ClearInvader();
            }
            _isDead = true;
        }
        else
        {
            if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Invader) ==
                GameManager.GAMEFEEL_ACTIVATION.Invader)
            {
                OnTakeDamage?.Invoke();   
            }
        }
    }

    public void OnMoveDown()
    {
        if(_isDead)
            return;
        
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Invader) == GameManager.GAMEFEEL_ACTIVATION.Invader)
        {
            OnLineChanged?.Invoke();
        }
    }

    public void Shoot()
    {
        Instantiate(bulletPrefab, shootAt.position, Quaternion.identity);
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Invader) == GameManager.GAMEFEEL_ACTIVATION.Invader)
        {
            OnSoot?.Invoke();
        }
    }

    public void ClearInvader()
    {
        Destroy(gameObject);
    }
}
