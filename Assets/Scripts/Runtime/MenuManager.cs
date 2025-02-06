using MoreMountains.Feedbacks;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    public static MenuManager Instance;

    [SerializeField] private CanvasGroup canvasGroup;
    [SerializeField] private MMF_Player mmf_Player;
    
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
        if (isOpen)
        {
            mmf_Player.PlayFeedbacks();
        }
        else
        {
            mmf_Player.StopFeedbacks();
        }
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
        EditorApplication.isPlaying = false;
#else 
        Application.Quit();
#endif
    }
}
