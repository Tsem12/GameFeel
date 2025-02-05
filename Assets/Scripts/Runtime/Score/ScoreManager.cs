using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class ScoreManager : MonoBehaviour
{

    [SerializeField, Min(1f)] private int _pointPerInvader;

    [Header("Score")]
    [SerializeField] private int _score;


    #region Text score
    private int _displayedScore;
    private float _scoreDisplaySpeed = 5f;
    [SerializeField] private TextMeshProUGUI _scoreText;
    #endregion



    #region Multiplier

    [Header("Multiplier")]
    [SerializeField] private TextMeshProUGUI _multiplierText;
    private bool _isMultiplierActive = false;

    [SerializeField] private Multipliers _multipliersScriptable;
    private int _currentMultiplierIndex;

    public static Action<Multipliers.Multiplier> onMultiplierChange;
    [SerializeField, Range(0f, 10f)] private float _multiplierDuration;
    [SerializeField] private Slider _multiplierSlider;

    private float _multiplierTimer;
    private int _multiplier;

    #region UnityEvents

    [Header("Unity Events")]
    public UnityEvent onScoreChange;

    [Header("Multiplier Increase")]
    public UnityEvent onMultiplierIncrease;
    public UnityEvent onMultiplierIncreaseToX5;
    public UnityEvent onMultiplierIncreaseToX15;

    [Header("Multiplier Decrease")]
    public UnityEvent onMultiplierDecrease;
    public UnityEvent onMultiplierDecreaseToX1;
    public UnityEvent onMultiplierDecreaseToX5;

    #endregion

    public int Multiplier => _multipliersScriptable.multipliers[_currentMultiplierIndex].multiplier;

    #endregion

    private void Reset()
    {
        _multiplierDuration = 5f;
        _pointPerInvader = 1;
    }

    private void Awake()
    {
        _score = 0;
        _multiplierTimer = 0f;
        _multiplier = 1;
    }

    private void Start()
    {
        UpdateTextScore();
        UpdateTextMultiplier();

        if (_multiplierSlider != null)
            _multiplierSlider.maxValue = _multiplierDuration;
    }

    // Update is called once per frame
    void Update()
    {
        if (_displayedScore < _score)
        {
            // je rajoute 5 au lerp pour ajouter les valeurs plus rapidement
            _displayedScore = (int)Mathf.Lerp(_displayedScore, _score + 5, _scoreDisplaySpeed * Time.deltaTime);

            // si le score affiché est plus grand que le score réel, je le remet à la valeur du score réel pour être sûr qu'il soit égal
            if (_displayedScore > _score)
                _displayedScore = _score;

            UpdateTextScore();
        }

        if (!_isMultiplierActive)
            return;

        UpdateSliderMultiplier();

        if (_multiplierTimer > 0)
        {
            _multiplierTimer -= Time.deltaTime;
        }
        else
        {
            if (Multiplier > 1)
            {
                DecreaseMultiplier();
                _multiplierTimer = _multiplierDuration;

            }
            else
            {
                _isMultiplierActive = false;
            }
        }
    }

    private void OnEnable()
    {
        Invader.OnDeathAction += DestroyedInvader;
    }

    private void OnDisable()
    {
        Invader.OnDeathAction -= DestroyedInvader;
    }

    private void DestroyedInvader(Invader invader)
    {
        AddScore(_pointPerInvader);
        _multiplierTimer = _multiplierDuration;
        _isMultiplierActive = true;
        IncreaseMultiplier();

        UpdateTextMultiplier();
    }

    private void IncreaseMultiplier()
    {

        if (IsOnLastMultiplier() && _multiplier == GetMultiplierFromScriptable())
            return;

        if(_multiplier < GetMaxMultiplier())
            _multiplier++;

        if (_multiplier > GetMultiplierFromScriptable())
            _currentMultiplierIndex++;

        onMultiplierChange?.Invoke(_multipliersScriptable.multipliers[_currentMultiplierIndex]);
        

        switch(_multiplier)
        {
            case 5:
                onMultiplierIncreaseToX5?.Invoke();
                break;
            case 15:
                onMultiplierIncreaseToX15?.Invoke();
                break;
        }

        UpdateTextMultiplier();
    }

    private bool IsOnLastMultiplier() => (_currentMultiplierIndex + 1) >= _multipliersScriptable.multipliers.Count;
    
    private int GetMaxMultiplier() => _multipliersScriptable.multipliers[_multipliersScriptable.multipliers.Count - 1].multiplier;
    private int GetMultiplierFromScriptable() => _multipliersScriptable.multipliers[_currentMultiplierIndex].multiplier;

    private void DecreaseMultiplier()
    {
        if (_currentMultiplierIndex > 0)
        {
            _currentMultiplierIndex--;
            _multiplier = _multipliersScriptable.multipliers[_currentMultiplierIndex].multiplier;
        }

        onMultiplierDecrease?.Invoke();

        switch (_multiplier)
        {
            case 1:
                onMultiplierDecreaseToX1?.Invoke();
                break;
            case 5:
                onMultiplierDecreaseToX5?.Invoke();
                break;
        }


        UpdateTextMultiplier();
    }

    public void AddScore(int value)
    {
        _score += value * _multiplier;
        onScoreChange?.Invoke();

    }

    private void UpdateTextScore()
    {
        if (_scoreText != null)
            _scoreText.text = _displayedScore.ToString();
    } 
    private void UpdateTextMultiplier()
    {
        if (_multiplierText != null)
            _multiplierText.text = "x" + _multiplier.ToString();
    }

    private void UpdateSliderMultiplier()
    {
        if (_multiplierSlider != null)
            _multiplierSlider.value = _multiplierTimer;
    }
}
