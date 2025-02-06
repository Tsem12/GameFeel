using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    public static MenuManager Instance;

    [SerializeField] private CanvasGroup canvasGroup;
    
    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
    }
    
    public bool IsMenuOpen { get; private set; }

    public void OpenMenu(bool isOpen)
    {
        IsMenuOpen = isOpen;
        Time.timeScale = isOpen ? 0 : 1;
        canvasGroup.alpha = isOpen ? 1 : 0;
        canvasGroup.interactable = isOpen;
    }

    public void ResumeGame()
    {
        OpenMenu(false);
    }

    public void RestartGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    public void QuitGame()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else 
        Application.Quit();
#endif
    }
}
