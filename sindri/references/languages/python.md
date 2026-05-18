# Python — Generic Patterns

Generic Python patterns for any well-engineered Python codebase. Load when writing or reviewing Python code. Domain-specific conventions belong in `domain.md`.

---

## Type annotations

Public functions always annotated. Private helpers annotated when the types are non-obvious. Return type always present.

```python
def fetch_user(user_id: int, *, include_deleted: bool = False) -> User | None:
    ...
```

`Optional[X]` is `X | None` in Python 3.10+. Prefer the union syntax.

Collections: `list[str]`, `dict[str, int]`, `tuple[int, str]` — lowercase, not `List`, `Dict`, `Tuple` from `typing`.

`TypeAlias` for complex types used in multiple places:

```python
UserID: TypeAlias = int
ResultMap: TypeAlias = dict[str, list[int]]
```

Run `mypy` or `pyright` in strict mode. Type annotations that don't pass the type checker are worse than no annotations — they mislead.

---

## Dataclasses over plain dicts

Structured data that moves between functions is a dataclass, not a dict:

```python
@dataclass(frozen=True)
class OrderSummary:
    order_id: int
    total: Decimal
    line_items: tuple[LineItem, ...]
```

`frozen=True` for value objects that shouldn't be mutated after creation. Prevents accidental mutation bugs.

`@dataclass` over `namedtuple` when you need default values, methods, or inheritance.

Plain dicts for truly dynamic key sets. If the keys are known at design time, it's a dataclass.

---

## Error handling

Specific exceptions, not bare `except:` or `except Exception:`. Catch what you expect; let the rest propagate.

```python
try:
    result = db.query(sql, params)
except DatabaseConnectionError as e:
    raise ServiceUnavailableError("database unreachable") from e
```

`raise X from e` preserves the original exception as cause. Never `raise X from None` unless suppressing the chain is intentional and documented.

Custom exception classes for domain errors. Inherit from the most specific built-in that applies:

```python
class UserNotFoundError(LookupError):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"user {user_id} not found")
        self.user_id = user_id
```

`finally` or context managers for resource cleanup:

```python
with open(path) as f:
    data = f.read()
# file always closed, even if read raises
```

---

## Paths and I/O

`pathlib.Path` everywhere. No `os.path.join`, no string concatenation for paths:

```python
from pathlib import Path

config_path = Path(__file__).parent / "config.yaml"
output_dir = Path(settings.output_dir)
output_dir.mkdir(parents=True, exist_ok=True)
```

Open files with explicit encoding: `open(path, encoding="utf-8")`. Never rely on platform default.

---

## Logging

`logging` module, not `print`. For libraries: `logging.getLogger(__name__)`. For applications: configure root logger at entry point.

```python
import logging

logger = logging.getLogger(__name__)

def process(item: Item) -> Result:
    logger.debug("processing item %s", item.id)
    result = _compute(item)
    logger.info("processed item %s → %s", item.id, result.status)
    return result
```

Structured logging for production services — use `structlog` or pass `extra={}` to include machine-parseable fields.

No f-strings in log calls — use `%s` formatting so the string is only interpolated if the log level is active.

---

## Testing

**pytest** everywhere. `unittest` only when inheriting an existing test suite that uses it.

Test file: `test_{module}.py`. Test function: `test_{what_it_does_and_expected_result}`.

**Fixtures** for shared setup:

```python
@pytest.fixture
def user(db: Session) -> User:
    return User(name="Alice", email="alice@example.com")
```

**Parametrize** for multiple input cases:

```python
@pytest.mark.parametrize("email,valid", [
    ("alice@example.com", True),
    ("not-an-email", False),
    ("", False),
])
def test_validate_email(email: str, valid: bool) -> None:
    assert validate_email(email) == valid
```

**`monkeypatch` and `pytest-mock`** for dependencies. Prefer dependency injection so tests don't need patching.

**`hypothesis`** for property-based tests on functions with invariants — especially parsers, serializers, and math.

No `assert` in test helpers — use `pytest.fail()` or raise `AssertionError` with a message. Plain `assert` gives poor failure output.

---

## Dependencies and environment

**`uv`** for dependency management (fast, modern). `requirements.txt` for simple scripts, `pyproject.toml` for packages and services.

Pin exact versions in `requirements.lock` / `uv.lock`. Never pin to a range in production — ">=1.2" means future CI runs get a different library.

Virtual environment per project. Never install to the system Python. `uv venv` / `python -m venv .venv`.

---

## Common patterns

**Context managers for resources:**

```python
class ManagedConnection:
    def __enter__(self) -> "ManagedConnection":
        self._conn = connect()
        return self

    def __exit__(self, *exc_info: object) -> None:
        self._conn.close()
```

**`__slots__` for high-volume value objects** (reduces memory, speeds attribute access):

```python
@dataclass
class Bar:
    __slots__ = ("timestamp", "open", "high", "low", "close", "volume")
    timestamp: datetime
    open: Decimal
    ...
```

**`@classmethod` factories** for alternative constructors:

```python
@classmethod
def from_dict(cls, data: dict[str, object]) -> "Config":
    return cls(host=str(data["host"]), port=int(data["port"]))
```

**Generator functions** for large sequences — don't load everything into memory:

```python
def iter_rows(path: Path) -> Iterator[Row]:
    with open(path) as f:
        for line in f:
            yield Row.from_line(line)
```

---

## What to avoid

- `global` variables. Pass state explicitly.
- Mutable default arguments (`def f(items=[])` — the list is shared across calls). Use `None` and create inside.
- `*args, **kwargs` in public APIs — callers lose type safety. Explicit parameters only.
- `eval()` and `exec()` with any input that isn't a literal you wrote.
- Bare `except:` — catches `KeyboardInterrupt` and `SystemExit`, which should propagate.
- `os.system()` for shell commands — use `subprocess.run()` with an explicit argument list.
