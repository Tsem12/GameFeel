using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Bullet : MonoBehaviour
{
    [SerializeField] Vector3 startVelocity; 
    public UnityEvent _dodgedEvent;

    // Start is called before the first frame update
    void Awake()
    {
        Rigidbody2D rb = GetComponent<Rigidbody2D>();
        rb.velocity = startVelocity;
        Destroy(gameObject, 10f);
    }
    
    public void Dodged()
    {
        if (GameManager.Instance.enableJuice)
        {
            _dodgedEvent?.Invoke();
        }
    }
}
