using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class ScoreManager : MonoBehaviour
{

    [SerializeField] private int _score;
    [SerializeField] private TextMeshProUGUI _scoreText;
    public int Score => _score;

    public UnityEvent onScoreChange;
    [SerializeField] private int _pointPerInvader;

    #region Multplier
    [SerializeField] private TextMeshProUGUI _multiplierText;
    private bool _isMultiplierActive = false;

    [SerializeField] private Multipliers _multipliersScriptable;
    [SerializeField] private int _currentMultiplierIndex;

    public static Action<Multipliers.Multiplier> onMultiplierChange;
    [SerializeField] private float _multiplierDuration;

    private float _multiplierTimer;
    private float _cumulativeScoreMultiplier;

    public int Multiplier => _multipliersScriptable.multipliers[_currentMultiplierIndex].multiplier;
    public float MultiplierDuration => _multiplierDuration;

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
    }

    private void Start()
    {
        UpdateTextScore();
        UpdateTextMultiplier();
    }

    // Update is called once per frame
    void Update()
    {
        if (!_isMultiplierActive)
            return;

        if(_multiplierTimer > 0)
        {
            _multiplierTimer -= Time.deltaTime;
        }
        else
        {
            if(Multiplier > 1)
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
        Invader.onDestroy += DestroyedInvader;
    }

    private void OnDisable()
    {
        Invader.onDestroy -= DestroyedInvader;
    }

    private void DestroyedInvader(Invader invader)
    {
        AddScore(_pointPerInvader);
        _cumulativeScoreMultiplier++;
        _multiplierTimer = _multiplierDuration;
        _isMultiplierActive = true;
        IncreaseMultiplier();

        if (_multiplierText != null)
            _multiplierText.text = "x" + Multiplier.ToString();
    }

    private void IncreaseMultiplier()
    {
        if (_cumulativeScoreMultiplier > _multipliersScriptable.multipliers[_currentMultiplierIndex].cumulativeScore)
        {
            if ((_currentMultiplierIndex + 1) >= _multipliersScriptable.multipliers.Count)
                return;

            _currentMultiplierIndex++;
            onMultiplierChange?.Invoke(_multipliersScriptable.multipliers[_currentMultiplierIndex]);
        }
        UpdateTextMultiplier();
    }

    private void DecreaseMultiplier()
    {
        if (_currentMultiplierIndex > 0)
        {
            _currentMultiplierIndex--;
            _cumulativeScoreMultiplier = 0;
        }

        UpdateTextMultiplier();
    }

    public void AddScore(int value)
    {
        _score += value * Multiplier;
        onScoreChange?.Invoke();
        UpdateTextScore();

    }

    private void UpdateTextScore()
    {
        if (_scoreText != null)
            _scoreText.text = _score.ToString();
    } 
    private void UpdateTextMultiplier()
    {
        if (_multiplierText != null)
            _multiplierText.text = "x" + Multiplier.ToString();
    }
}
