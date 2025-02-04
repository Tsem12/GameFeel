using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] private int numberOfLives = 3;

    [SerializeField] private Bullet bulletPrefab;
    [SerializeField] private Transform shootAt;
    [SerializeField] private float shootCooldown = 1f;
    [SerializeField] private string collideWithTag = "Untagged";

    private float lastShootTimestamp = Mathf.NegativeInfinity;
    
    [Header("Movement parameters")]
    [SerializeField, Min(0f)] private float maxVelocity = 3;
    [SerializeField, Min(0f)] private float acceleration = 1f;
    [SerializeField, Range(0f, 1f)] private float decelerationRate = .95f;
    [SerializeField] private AnimationCurve accelerationCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);

    private float velocity;

    void Update()
    {
        UpdateMovement();
        UpdateActions();
    }

    void UpdateMovement()
    {
        float TrueSign(float value)
        {
            return value == 0 ? 0 : value > 0 ? 1 : -1; 
        } 
        float moveDir = TrueSign(Input.GetAxis("Horizontal"));
        if (moveDir == 0)
        {
            velocity *= decelerationRate;
        }
        else
        {
            velocity = Mathf.Clamp(velocity + moveDir * acceleration * Time.deltaTime, -maxVelocity, maxVelocity);
        }

        Vector3 newPos = GameManager.Instance.KeepInBounds(transform.position + Vector3.right * velocity);
        if (Mathf.Abs(transform.position.x - newPos.x) < Mathf.Epsilon)
        {
            velocity = 0;
        }
        transform.position = newPos;
    }


    void UpdateActions()
    {
        if (Input.GetKey(KeyCode.Space) 
            && Time.time > lastShootTimestamp + shootCooldown )
        {
            Shoot();
        }
    }

    void Shoot()
    {
        Instantiate(bulletPrefab, shootAt.position, Quaternion.identity);
        lastShootTimestamp = Time.time;
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if (!collision.gameObject.CompareTag(collideWithTag)) return;
        Destroy(collision.gameObject);

        velocity = 0f;
        CheckLives();
    }

    private void CheckLives()
    {
        numberOfLives--;
        if (numberOfLives <= 0)
        {
            GameManager.Instance.PlayGameOver();
        }
    }
}