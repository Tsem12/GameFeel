using UnityEngine;
using UnityEngine.SceneManagement;

public class PageSteam : MonoBehaviour
{
    public void OnClickLoadMenu()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
