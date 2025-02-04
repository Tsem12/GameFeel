using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoreManager : MonoBehaviour
{

    [SerializeField] private int _score;
    public int Score => _score;
    public static Action<int> onScoreChange;

    #region Multplier
    [SerializeField] private Multipliers _multipliers;
    [SerializeField] private int _currentMultiplierIndex;

    private bool _isMultiplierActive = false;

    [SerializeField] private int _multiplier;
    public int Multiplier => _multiplier;

    [SerializeField] private float _multiplierDuration;
    public float MultiplierDuration => _multiplierDuration;

    private float _multiplierTimer;
    private float _cumulativeScoreMultiplier;

    #endregion

    private void Reset()
    {
        _multiplierDuration = 5f;
    }

    private void Awake()
    {
        _score = 0;
        _multiplierTimer = 0f;
        _multiplier = 1;
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
            if(_multiplier > 1)
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
        AddScore(1);
        _multiplierTimer = _multiplierDuration;
        _isMultiplierActive = true;
        IncreaseMultiplier();
    }

    private void IncreaseMultiplier()
    {
        if (_cumulativeScoreMultiplier > _multipliers.multipliers[_currentMultiplierIndex].cumulativeScore)
        {
            if ((_currentMultiplierIndex + 1) >= _multipliers.multipliers.Count)
                return;

            _currentMultiplierIndex++;
            _multiplier = (int)_multipliers.multipliers[_currentMultiplierIndex].multiplier;
        }
    }

    private void DecreaseMultiplier()
    {
        if (_currentMultiplierIndex > 0)
        {
            _currentMultiplierIndex--;
            _multiplier = (int)_multipliers.multipliers[_currentMultiplierIndex].multiplier;
            _cumulativeScoreMultiplier = 0;
        }
    }

    public void AddScore(int value)
    {
        _score += value * _multiplier;
        onScoreChange?.Invoke(_score);
        _cumulativeScoreMultiplier += 1;
    }
}
