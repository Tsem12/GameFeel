using System;
using MoreMountains.Feedbacks;
using UnityEngine;
using UnityEngine.Events;

public class Player : MonoBehaviour
{
    [SerializeField] private Bullet bulletPrefab;
    [SerializeField] private Transform shootAt;
    [SerializeField] private float shootCooldown = 1f;
    [SerializeField] private string collideWithTag = "Untagged";
    [SerializeField] private MMF_Player wigglePlayer;
    [SerializeField] private Rigidbody2D _rb;

    [SerializeField] private UnityEvent OnShoot;
    
    private float lastShootTimestamp = Mathf.NegativeInfinity;
    public bool IsInvicible { get; set; }

    [Header("Movement parameters")]
    [SerializeField] private PlayerMovementStateMachine playerMovementStateMachine;

    #region Player life
    [Header("Player life")]
    [SerializeField, Min(0f)] private int numberOfLives = 3;
    public UnityEvent onFirstLifeLost;
    public UnityEvent onSecondLifeLost;
    public UnityEvent OnTakeDamage;
    public static Action OnTakeDamageAction;

    private bool _isDead;
    #endregion

    private void Awake()
    {
        _rb = GetComponent<Rigidbody2D>();
    }

    private void Start()
    {
        playerMovementStateMachine.Initialize(this);
        GameManager.onGamefeelChanged += OnGameFeelChanged;
        GameManager.Instance.onGameOver.AddListener(() => _rb.bodyType = RigidbodyType2D.Dynamic);
    }
    
    

    private void Update()
    {
        if(_isDead)
            return;
        
        UpdateMovement();
        UpdateActions();
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            MenuManager.Instance.OpenMenu(!MenuManager.Instance.IsMenuOpen);
        }
        //Debug.Log(playerMovementStateMachine.DashingState._dodgeParticule.isPlaying);
    }

    private void OnDestroy()
    {
        GameManager.onGamefeelChanged -= OnGameFeelChanged;
        GameManager.Instance.onGameOver.RemoveAllListeners();
    }

    private void UpdateMovement()
    {
        if(_isDead)
            return;
        
        playerMovementStateMachine?.Update(Time.deltaTime);
    }

    private void UpdateActions()
    {
        if (Input.GetKey(KeyCode.Space) 
            && Time.time > lastShootTimestamp + shootCooldown )
        {
            Shoot();
        }
    }

    private void Shoot()
    {
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
        {
            OnShoot?.Invoke();
        }
        Instantiate(bulletPrefab, shootAt.position, Quaternion.identity);
        lastShootTimestamp = Time.time;
    }

    public void OnTriggerEnter2D(Collider2D collision)
    {
        if (!collision.gameObject.CompareTag(collideWithTag) || IsInvicible) return;
        Destroy(collision.gameObject);

        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
            OnTakeDamage?.Invoke();

        OnTakeDamageAction?.Invoke();
        CheckLives();
    }

    private void CheckLives()
    {
        if(_isDead)
            return;
        
        numberOfLives--;
        switch(numberOfLives)
        {
            case 2:
                if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
                    onFirstLifeLost?.Invoke();
                break;
            case 1:
                if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
                    onSecondLifeLost?.Invoke();
                break;
            default:
                _rb.bodyType = RigidbodyType2D.Dynamic;
                GameManager.Instance.PlayGameOver();
                _isDead = true;
                break;
        }
    }
    
    
    public static int Sign(float value)
    {
        return (Mathf.Abs(value) < Mathf.Epsilon) ? 0 : (value > 0 ? 1 : -1);
    }
    
    public enum PlayerMovementStateType
    {
        Idle,
        Accelerating,
        Decelerating,
        TurningBack,
        Dashing,
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, playerMovementStateMachine.DashingState.PerfectDodgeRadius);
    }

    private void OnGameFeelChanged()
    {
        if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) != GameManager.GAMEFEEL_ACTIVATION.Player)
        {
            wigglePlayer.StopFeedbacks();
            wigglePlayer.RestoreInitialValues();
            transform.rotation = Quaternion.identity;
        }
        else
        {
            wigglePlayer.PlayFeedbacks();
        }
    }
    
    // private void OnGUI()
    // {
    //     GUI.Label(new Rect(10, 10, Screen.width, Screen.height), $"_stateMachine.currentState: {playerMovementStateMachine.CurrentState}\n" +
    //                                                              $"_stateMachine.Velocity: {playerMovementStateMachine.Velocity}\n" +
    //                                                              $"_stateMachine.MoveDir: {playerMovementStateMachine.MoveDir}\n" +
    //                                                              $"_stateMachine.XValue: {playerMovementStateMachine.XValue}\n");
    // }
    
    [Serializable]
    private class PlayerMovementStateMachine
    {
        private Player _player;
        
        [Header("Movement parameters")]
        [SerializeField] private float velocityMultiplier;
        [SerializeField] private float maxRotationangle;
        [SerializeField, Min(0f)] private float dashCooldown;

        
        [Header("States parameters")]
        [SerializeField] private IdleMovementState idleState;
        [SerializeField] private AcceleratingMovementState acceleratingState;
        [SerializeField] private DeceleratingMovementState deceleratingState;
        [SerializeField] private TurningBackMovementState turningBackState;
        [SerializeField] private DashingMovementState dashingState;
        
        
        public PlayerMovementStateType CurrentStateType { get; private set; }
        public PlayerMovementState CurrentState => GetState(CurrentStateType);
        
        public int MoveDir { get; private set; }
        public bool IsDashing { get; private set; }
        public float Velocity { get; set; }
        public float XValue { get; set; }

        public DashingMovementState DashingState => dashingState;

        private float currentDashCooldown;
        
        public void Initialize(Player player)
        {
            _player = player;
            idleState.Init(this, player);
            acceleratingState.Init(this, player);
            deceleratingState.Init(this, player);
            turningBackState.Init(this, player);
            DashingState.Init(this, player);
            CurrentStateType = PlayerMovementStateType.Idle;
            CurrentState.StartState(PlayerMovementStateType.Idle);
        }
        
        public void Update(float deltaTime)
        {
            MoveDir = Sign(Input.GetAxis("Horizontal"));
            IsDashing = Input.GetKeyDown(KeyCode.W) && currentDashCooldown <= 0;
            if (currentDashCooldown > 0)
            {
                currentDashCooldown -= deltaTime;
            }
            CurrentState?.Update(deltaTime);
            if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player )
            {
                _player.transform.rotation = Quaternion.Euler(0f, XValue * Sign(Velocity) * maxRotationangle, 0f);
            }
            Vector3 newPos = GameManager.Instance.KeepInBounds(_player.transform.position
                                                               + Vector3.right * (Velocity * velocityMultiplier * deltaTime));
            if (Mathf.Abs(_player.transform.position.x - newPos.x) < Mathf.Epsilon)
            {
                Velocity = 0;
            }
            _player.transform.position = newPos;
        }
        
        public void ChangeState(PlayerMovementStateType newState)
        {
            if (newState == CurrentStateType) return;
            CurrentState?.StopState(newState);
            PlayerMovementStateType oldStateType = CurrentStateType;
            CurrentStateType = newState;
            CurrentState?.StartState(oldStateType);
        }
        
        private PlayerMovementState GetState(PlayerMovementStateType stateType)
        {
            return stateType switch
            {
                PlayerMovementStateType.Idle => idleState,
                PlayerMovementStateType.Accelerating => acceleratingState,
                PlayerMovementStateType.Decelerating => deceleratingState,
                PlayerMovementStateType.TurningBack => turningBackState,
                PlayerMovementStateType.Dashing => DashingState,
                _ => idleState,
            };
        }

        public void ResetDashCooldown()
        {
            currentDashCooldown = dashCooldown;
        }
    }
    
    private abstract class PlayerMovementState
    {
        protected PlayerMovementStateMachine _stateMachine;
        protected Player _player;

        [SerializeField, Min(0.01f)] protected float durationTime;
        
        public void Init(PlayerMovementStateMachine stateMachine, Player player)
        {
            _player = player;
            _stateMachine = stateMachine;
        }

        public virtual void Update(float deltaTime)
        {
            _stateMachine.XValue = Mathf.Clamp01(_stateMachine.XValue + ( 1f / durationTime) * deltaTime);
        }
        
        public abstract void StartState(PlayerMovementStateType previousState);
        public abstract void StopState(PlayerMovementStateType nextState);
    }

    [Serializable]
    private class IdleMovementState : PlayerMovementState
    {
        public override void Update(float deltaTime)
        {
            if (_stateMachine.IsDashing)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Dashing);
            }
            else if (_stateMachine.MoveDir != 0)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Accelerating);
            }
        }

        public override void StartState(PlayerMovementStateType previousState)
        {
            _stateMachine.Velocity = 0f;
        }

        public override void StopState(PlayerMovementStateType nextState)
        {
        }
    }
    
    [Serializable]
    private class AcceleratingMovementState : PlayerMovementState
    {
        [SerializeField] private AnimationCurve accelerationCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);
        
        public override void Update(float deltaTime)
        {
            base.Update(deltaTime);
            if (_stateMachine.IsDashing && _stateMachine.CurrentState != _stateMachine.DashingState)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Dashing);
            }
            else if (_stateMachine.MoveDir == 0)
            {
                _stateMachine.ChangeState(Mathf.Abs(_stateMachine.Velocity) > 0 ?
                    PlayerMovementStateType.Decelerating : PlayerMovementStateType.Idle);
            }
            else if (_stateMachine.MoveDir != Sign(_stateMachine.Velocity) && Sign(_stateMachine.Velocity) != 0)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.TurningBack);
            }
            else
            {
                _stateMachine.Velocity = accelerationCurve.Evaluate(_stateMachine.XValue) * _stateMachine.MoveDir;
            }
        }

        public override void StartState(PlayerMovementStateType previousState)
        {
        }

        public override void StopState(PlayerMovementStateType nextState)
        {
        }
    }
    
    [Serializable]
    private class DeceleratingMovementState : PlayerMovementState
    {
        [SerializeField] private AnimationCurve decelerationCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);
        
        public override void Update(float deltaTime)
        {
            base.Update(-deltaTime);
            if (_stateMachine.IsDashing)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Dashing);
            }
            else if (_stateMachine.MoveDir != 0)
            {
                _stateMachine.ChangeState(_stateMachine.MoveDir != Sign(_stateMachine.Velocity) ?
                    PlayerMovementStateType.TurningBack : PlayerMovementStateType.Accelerating);
            }
            else if (_stateMachine.XValue < Mathf.Epsilon)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Idle);
            }
            else
            {
                _stateMachine.Velocity = decelerationCurve.Evaluate(_stateMachine.XValue) * Sign(_stateMachine.Velocity);
            }
        }

        public override void StartState(PlayerMovementStateType previousState)
        {
        }

        public override void StopState(PlayerMovementStateType nextState)
        {
        }
    }
    
    [Serializable]
    private class TurningBackMovementState : PlayerMovementState
    {
        [SerializeField] private AnimationCurve decelerationCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);
        
        public override void Update(float deltaTime)
        {
            base.Update(-deltaTime);
            if (_stateMachine.IsDashing)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Dashing);
            }
            else if (_stateMachine.MoveDir == 0)
            {
                _stateMachine.ChangeState(Mathf.Abs(_stateMachine.Velocity) > 0 ?
                    PlayerMovementStateType.Decelerating : PlayerMovementStateType.Idle);
            }
            else if (Sign(_stateMachine.Velocity) == _stateMachine.MoveDir 
                     || _stateMachine.XValue < Mathf.Epsilon)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Accelerating);
            }
            else
            {
                _stateMachine.Velocity = decelerationCurve.Evaluate(_stateMachine.XValue) * -Sign(_stateMachine.MoveDir);
            }
        }

        public override void StartState(PlayerMovementStateType previousState)
        {
        }

        public override void StopState(PlayerMovementStateType nextState)
        {
            _stateMachine.Velocity = 0f;
        }
    }
    
    [Serializable]
    private class DashingMovementState : PlayerMovementState
    {
        [SerializeField] private AnimationCurve dashCurve = AnimationCurve.EaseInOut(0f, 0f, 1f, 1f);
        [SerializeField, Min(1f)] private float dashSpeedMultiplier;

        [SerializeField] private UnityEvent onDashStart;
        [SerializeField] private UnityEvent onDashEnd;
        [SerializeField] public ParticleSystem _dodgeParticule;
        
        [Header("PerfectDodge")]
        [SerializeField] private float _perfectDodgeRadius;
        [SerializeField] private LayerMask _dodgeLayer;
        [SerializeField] private UnityEvent onDashPerfect;

        private float timerCount;
        private float startMoveDir;

        public float PerfectDodgeRadius => _perfectDodgeRadius;

        public override void Update(float deltaTime)
        {
            timerCount += deltaTime * ( 1f / durationTime);
            _stateMachine.Velocity = (1 + dashCurve.Evaluate(timerCount) * dashSpeedMultiplier) * startMoveDir;
            if (timerCount >= 1f)
            {
                _stateMachine.ChangeState(PlayerMovementStateType.Accelerating);
            }
        }
        

        public override void StartState(PlayerMovementStateType previousState)
        {
            timerCount = 0;
            startMoveDir = _stateMachine.MoveDir;
            _player.IsInvicible = true;
            onDashStart?.Invoke();
            if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
            {
                _dodgeParticule.Play();
            }

            Collider2D r = Physics2D.OverlapCircle(_player.transform.position, PerfectDodgeRadius, _dodgeLayer);
            if (r)
            {
                if ((GameManager.Instance.GamefeelActivation & GameManager.GAMEFEEL_ACTIVATION.Player) == GameManager.GAMEFEEL_ACTIVATION.Player)
                {
                    onDashPerfect?.Invoke();
                }
                r.GetComponent<Bullet>()?.Dodged();
            }
        }

        public override void StopState(PlayerMovementStateType nextState)
        {
            _stateMachine.Velocity = 1f;
            _stateMachine.XValue = _stateMachine.MoveDir;
            _player.IsInvicible = false;
            _stateMachine.ResetDashCooldown();
            onDashEnd?.Invoke();
            _dodgeParticule.Stop();
        }
    }
}