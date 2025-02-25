using System;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;

[DefaultExecutionOrder(-100)]
public class GameManager : MonoBehaviour
{
    [Flags]
    public enum GAMEFEEL_ACTIVATION{Player = 1, Invader = 2, Combo = 4}
    public enum DIRECTION { Right = 0, Up = 1, Left = 2, Down = 3 }

    public static GameManager Instance = null;

    [SerializeField] private Vector2 bounds;
    private Bounds Bounds => new Bounds(transform.position, new Vector3(bounds.x, bounds.y, 1000f));

    public GAMEFEEL_ACTIVATION GamefeelActivation => _gamefeelActivation;

    [SerializeField] private float gameOverHeight;

    public static Action onGamefeelChanged;
    public UnityEvent onGameOver;

    [SerializeField] private CanvasGroup _menu;

    public GAMEFEEL_ACTIVATION _gamefeelActivation = GAMEFEEL_ACTIVATION.Combo | GAMEFEEL_ACTIVATION.Invader | GAMEFEEL_ACTIVATION.Player;

    public bool _isGameOver;

    void Awake()
    {
        Instance = this;
        _gamefeelActivation = GAMEFEEL_ACTIVATION.Combo | GAMEFEEL_ACTIVATION.Invader | GAMEFEEL_ACTIVATION.Player;
    }

    public Vector3 KeepInBounds(Vector3 position)
    {
        return Bounds.ClosestPoint(position);
    }

    public float KeepInBounds(float position, DIRECTION side)
    {
        switch (side)
        {
            case DIRECTION.Right: return Mathf.Min(position, Bounds.max.x);
            case DIRECTION.Up: return Mathf.Min(position, Bounds.max.y);
            case DIRECTION.Left: return Mathf.Max(position, Bounds.min.x);
            case DIRECTION.Down: return Mathf.Max(position, Bounds.min.y);
            default: return position;
        }
    }

    public bool IsInBounds(Vector3 position)
    {
        return Bounds.Contains(position);
    }

    public bool IsInBounds(Vector3 position, DIRECTION side)
    {
        switch (side)
        {
            case DIRECTION.Right: case DIRECTION.Left: return IsInBounds(position.x, side);
            case DIRECTION.Up: case DIRECTION.Down: return IsInBounds(position.y, side);
            default: return false;
        }
    }

    public bool IsInBounds(float position, DIRECTION side)
    {
        switch (side)
        {
            case DIRECTION.Right: return position <= Bounds.max.x;
            case DIRECTION.Up: return position <= Bounds.max.y;
            case DIRECTION.Left: return position >= Bounds.min.x;
            case DIRECTION.Down: return position >= Bounds.min.y;
            default: return false;
        }
    }

    public bool IsBelowGameOver(float position)
    {        
        return position < transform.position.y + (gameOverHeight - bounds.y * 0.5f);
    }

    public void PlayGameOver()
    {
        if(_isGameOver)
            return;
        _isGameOver = true;
        Debug.Log("Game Over");
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) ==
            GameManager.GAMEFEEL_ACTIVATION.Player)
        {
            _menu.interactable = true;
            onGameOver?.Invoke();
        }
        else
        {
            _menu.interactable = true;
            _menu.alpha = 1;
        }

    }

    public void OnDrawGizmos()
    {
        Gizmos.color = Color.gray;
        Gizmos.DrawWireCube(transform.position, new Vector3(bounds.x, bounds.y, 0f));

        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(
            transform.position + Vector3.up * (gameOverHeight - bounds.y * 0.5f) - Vector3.right * bounds.x * 0.5f,
            transform.position + Vector3.up * (gameOverHeight - bounds.y * 0.5f) + Vector3.right * bounds.x * 0.5f);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Keypad1))
        {
            _gamefeelActivation ^= GAMEFEEL_ACTIVATION.Player;
            onGamefeelChanged?.Invoke();
        }
        else if(Input.GetKeyDown(KeyCode.Keypad2))
        {
            _gamefeelActivation ^= GAMEFEEL_ACTIVATION.Combo;
            onGamefeelChanged?.Invoke();
        }
        else if(Input.GetKeyDown(KeyCode.Keypad3))
        {
            _gamefeelActivation ^= GAMEFEEL_ACTIVATION.Invader;
            onGamefeelChanged?.Invoke();
        }

        if (Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene(0);
        }
    }
}
