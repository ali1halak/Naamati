# AGENTS.md — Naamati Frontend (Flutter)

Rules and conventions for AI agents (and humans) editing this project. Read this
file **before** making any changes. If a rule here contradicts what you find in
code, apply the rule and flag the discrepancy.

---

## 1. Project Overview

- **App:** Naamati (نعمتي) — an Arabic RTL app for growing plants/garden management.
- **Framework:** Flutter (Dart SDK `^3.11.1`), Material 3.
- **Architecture:** **Clean Architecture** with a **feature-first** folder layout.
- **State management:** `flutter_bloc` — the app uses **Cubits** (not full Blocs).
- **The target platform folder structure is:**
  ```
  lib/
    main.dart
    core/        (cross-cutting, feature-agnostic)
    features/    (one folder per domain feature)
  ```

### Non-negotiable architecture rules

- **Never** put feature code in `lib/core/`.
- **Never** reference an entity (domain) from `data/`, or a model from `presentation/`/`domain/`.
- Dependencies must point **inward**: `presentation → domain ← data`.
  - `presentation/` depends only on `domain/` (not `data/`).
  - `data/` depends on `domain/` (implements the domain repository interface).
  - `domain/` has **zero** Flutter and **zero** third-party-package dependencies
    except `dartz`, `equatable` and other pure-Dart helpers.

---

## 2. Folder Structure (feature-first + clean architecture)

Each feature lives under `lib/features/<feature>/`, split into three layers:

```
lib/features/<feature>/
  data/
    datasources/      # Retrofit REST API definitions (+ cached/local sources)
    models/           # JSON models (json_serializable) + generated *.g.dart
    repositories/     # Concrete repository implementations
  domain/
    entities/         # Pure business objects (extend Equatable)
    repositories/     # Abstract repository contracts (interfaces)
    usecases/         # Business use cases (implements core UseCase<T, P>)
  presentation/
    bloc/             # Cubit + State classes for this feature
    pages/            # Screens for this feature
    (widgets/)        # Feature-specific widgets, if needed
```

### Core layer

```
lib/core/
  base/        # base_state.dart (BlocStatus enum + markers)
  constants/   # api_constants.dart, app_constants.dart, storage_keys.dart
  di/          # injection_container.dart + *.config.dart (generated)
  error/       # failures.dart, exceptions.dart
  network/     # dio_client.dart, error_mapper.dart, network_info.dart
  routes/      # app_router.dart, route_names.dart
  theme/       # app_theme.dart, app_colors.dart, app_text_styles.dart
  usecases/    # usecase.dart (UseCase<T,P>, StreamUseCase, NoParams)
  utils/       # validators.dart, input_converter.dart
  widgets/     # Reusable UI: CustomButton, CustomTextField, loading, error, empty
```

---

## 3. Adding a New Feature (step-by-step)

To add a feature named `<feature>` (e.g. `products`), follow this exact order so
compilation never breaks:

1. **Create the folder tree** under `lib/features/<feature>/` with `data/`,
   `domain/`, `presentation/` subfolders described above.

2. **Domain — entity** (`domain/entities/xyz.dart`): plain class extending
   `Equatable`. No imports from `data/`, `package:flutter`, or packages.

3. **Domain — repository contract** (`domain/repositories/<feature>_repository.dart`):
   `abstract class XyzRepository { Future<Either<Failure, T>> method(...); }`
   Return `Either<Failure, T>` from `package:dartz`.

4. **Domain — use case(s)** (`domain/usecases/*.dart`):
   - Annotate with `@lazySingleton`.
   - Implement `UseCase<T, Params>` (or `StreamUseCase<T, Params>`).
   - If no input is needed, pass `NoParams` (defined in `core/usecases/usecase.dart`).
   - If input is needed, define a `XxxParams extends Equatable` class in the same file.
   - Named constructor injection of the repository (`XyzUseCase(this._repository);`).

5. **Data — models** (`data/models/*.dart`):
   - `@JsonSerializable()` annotated, `part '*.g.dart';`.
   - For an entity, extend it: `class XyzModel extends XyzEntity` and forward all
     constructor args with `super`.
   - Use `@JsonKey(name: 'snake_case')` to map snake_case API fields.
   - Every model exposes `fromJson` and `toJson` factories calling the generated
     `_$XxxFromJson` / `_$XxxToJson`.

6. **Data — data source** (`data/datasources/*_remote_data_source.dart`):
   - `@RestApi()` abstract class with a `@factoryMethod` factory returning the
     `_`-private implementation:
     ```dart
     @RestApi()
     abstract class XyzRemoteDataSource {
       @factoryMethod
       factory XyzRemoteDataSource(Dio dio) = _XyzRemoteDataSource;
       // ...
     }
     ```
   - Annotate endpoint methods with `@GET(...)`, `@POST(...)` etc. Use paths from
     `core/constants/api_constants.dart` when the endpoint is shared, otherwise a
     feature-local constant path string.
   - Retrofit will generate `*_remote_data_source.g.dart`; add `part '<name>.g.dart';`
     at the top.

7. **Data — repository implementation** (`data/repositories/<feature>_repository_impl.dart`):
   - `@LazySingleton(as: XyzRepository)`.
   - `implements XyzRepository`.
   - Inject the remote data source + `NetworkInfo` (constructor injection, private fields).
   - Guard remote calls with `if (await networkInfo.isConnected) { ... } else { return Left(const NetworkFailure()); }`.
   - Wrap the remote call in `try/catch`; in `catch (e)` return
     `Left(mapExceptionToFailure(e))` from `core/network/error_mapper.dart`.
   - On a non-success response, return `Left(ServerFailure(message: ...))`.

8. **Presentation — state** (`presentation/bloc/<feature>_state.dart`):
   - `extends Equatable`, carries a `BlocStatus status` field from
     `core/base/base_state.dart`, plus an optional `errorMessage` and the relevant data.
   - Provide `isLoading` / `isSuccess` / `isFailure` getters.
   - Provide a `copyWith` method.
   - Provide `props` covering every field.

9. **Presentation — cubit** (`presentation/bloc/<feature>_cubit.dart`):
   - `@injectable`.
   - `extends Cubit<XyzState>` with `super(const XyzState())`.
   - Inject the use case(s) as private final fields.
   - Emit `copyWith(status: BlocStatus.loading)` first, then `result.fold(...)`
     mapping failure → `BlocStatus.failure` and success → `BlocStatus.success`.

10. **Presentation — page(s)** (`presentation/pages/*.dart`):
    - Top-level `XyzPage` is a `StatelessWidget` that provides the cubit via
      `BlocProvider(create: (context) => sl<XyzCubit>(), child: const _XyzPageView())`.
    - The private `_XyzPageView` holds the actual UI and reads state via
      `BlocBuilder` / `BlocListener`.
    - Obtaining the cubit: `sl<XyzCubit>()` from `core/di/injection_container.dart`.
    - Arabic UI: wrap content in `Directionality(textDirection: TextDirection.rtl, ...)`.
    - Use `AppConstants` spacing, `AppTextStyles`, `AppColors`, and reusable
      `CustomButton` / `CustomTextField` / loading / error / empty widgets.
    - Apply `flutter_screenutil` extensions to every dimension/text size (§7).

11. **Register in DI** (`lib/core/di/injection_container.dart`): `injectable_generator`
    auto-registers `@injectable`/`@lazySingleton` items — but if you instantiate a
    new core dependency, register it in `CoreModule`. Then run code generation (see §5).

12. **Wire up routing** (`lib/core/routes/`):
    - Add a path constant to `route_names.dart`.
    - Add a `GoRoute(...)` entry to `_routes` in `app_router.dart`.

13. **Run the build_runner + analyze** (see §5) and fix any issues.

> **Tip:** Mirror the existing `auth` feature as your template — it is the reference
> implementation for every layer above.

---

## 4. Code Generation (build_runner)

This project uses `retrofit`, `injectable`, and `json_serializable`, all of which
generate code into `*.g.dart` / `*.config.dart` files. **You must regenerate after**
creating/editing any data source, model, or DI registration.

```powershell
dart run build_runner build
```

The key generated files (tracked/needed at runtime):
- `lib/core/di/injection_container.config.dart`
- `lib/features/<feature>/data/datasources/*.g.dart`
- `lib/features/<feature>/data/models/*.g.dart`

**Never** hand-edit generated `*.g.dart` / `*.config.dart` files. Edit the source
and re-run build_runner.

---

## 5. Commands

Run these from the project root (`D:\projects\Naamati\frontend`). All use PowerShell.

| Task | Command |
|------|---------|
| Code generation | `dart run build_runner build` |
| Static analysis / lints | `flutter analyze` |
| Format all code | `dart format lib` |
| Run tests | `flutter test` |
| Run app | `flutter run` |
| Pull latest deps | `flutter pub get` |

**Always** run `flutter analyze` after finishing edits and fix all issues (see §7).

---

## 6. Coding Conventions & Clean Code

### General / Dart
- Follow `flutter_lints` defaults (`flutter_lints: ^6.0.0`).
- Use **`final`** for all fields; use `const` for constructors/create where possible.
- Private helpers that don't need state go in private `_` classes; keep files focused
  and small. Split large widgets into private sub-widgets in the same file.
- **Never add code comments to explain what the code does** — comments are reserved
  for *why* / API contracts / non-obvious decisions. Match the existing doc-comment style
  (`///`) used across the codebase.
- No `print()`; use the `logger` package or `debugPrint` (guarded by `kDebugMode`).

### Error handling (critical)
- `domain` returns `Either<Failure, T>` from `dartz`. Always handle both `Left` and `Right`
  via `.fold(...)`.
- Reuse the existing failure types in `core/error/failures.dart`
  (`ServerFailure`, `CacheFailure`, `NetworkFailure`, `ValidationFailure`, `UnknownFailure`).
- Convert caught exceptions with `mapExceptionToFailure` in `core/network/error_mapper.dart`.

### Dependency injection
- Use `get_it` + `injectable`. Prefer the generated registrations:
  - `@injectable` for Cubits (and transient things).
  - `@lazySingleton` for repositories and use cases.
  - `@LazySingleton(as: <Interface>)` for repository implementations bound to their
    abstract interface.
- Resolve from `sl` (`GetIt.instance`) — do **not** create dependencies with `new` in
  pages; use `sl<XyzCubit>()`.

### Networking
- **Never** construct a raw `Dio` in a data source. Inject the configured instance via
  `DioClient.create(...)` registered in `CoreModule` → `Dio`.
- Retrofit data sources only — no manual `http` calls.

### Storage
- Tokens / secrets → `FlutterSecureStorage` (keys in `storage_keys.dart`).
- Non-sensitive preferences → `SharedPreferences`.

### Environment
- Config lives in `.env`; load via `flutter_dotenv`. Never commit real secrets.
  Add missing keys to `.env.example`.

### Validation
- Put reusable form validators in `core/utils/validators.dart`
  (`emailValidator`, `passwordValidator`, `phoneValidator`,
  `requiredFieldValidator`, `confirmPasswordValidator`).
- Argument/input validation on use cases lives in `core/utils/input_converter.dart` when
  there is conversion logic; otherwise validate in the model/cubit.

### naming
- Files: `snake_case.dart`. Classes: `PascalCase`. Fields/methods: `camelCase`.
- Feature files prefixed with the feature name: `login_cubit.dart`, `user_model.dart`.

---

## 7. Theme & UI Rules

- **Colors:** use `AppColors` tokens (`core/theme/app_colors.dart`). Brand colors are
  `AppColors.primary`/`secondary` etc. The actual Naamati green/beige from the login
  screen live at `AppColors.brandGreen` (`0xFF1E4632`) and `AppColors.brandBeige`
  (`0xFFF9F7F3`). **Never** hard-code color literals in widget code.
- **Typography:** use `AppTextStyles` (`core/theme/app_text_styles.dart`), never raw
  `TextStyle(...)` with literals.
- **Spacing:** always use `AppConstants` (`paddingSM`…`paddingXXL`, `margin*`, `radius*`,
  `buttonHeight`, `inputHeight`). No magic numbers.
- **Responsive sizing:** the app uses **`flutter_screenutil`**. Always apply its
  extensions to dimensions and text instead of raw `double` values:
  - `.w` for widths / horizontal values, `.h` for heights / vertical values,
    `.r` for sizes and radii that should scale in both dimensions (and for square
    containers/icons), `.sp` for font sizes.
  - Example: `SizedBox(height: AppConstants.paddingLG.h)`,
    `BorderRadius.circular(AppConstants.radiusXL.r)`, `Icon(..., size: 36.r)`.
  - Sizing must be relative to the design size configured in `ScreenUtilInit`
    (`390 x 844`). Text sizes that are already font-size based (`AppTextStyles.sp`)
    may use `.sp` where scaling is desired (e.g. `AppTextStyles.headlineMedium.sp`).
  - `ScreenUtilInit` is set up once in `lib/main.dart` — do not add another instance.
- **Buttons:** use `CustomButton` (`core/widgets/custom_button.dart`) for primary/action
  buttons and loading states. It disables while `isLoading`.
- **Text fields:** use `CustomTextField` (`core/widgets/custom_textfield.dart`) with the
  existing `validator` helpers. It reads colors from the active theme.
- Reuse loading (`loading_indicator.dart`), error (`app_error_widget.dart`) and
  empty-state (`empty_state_widget.dart`) widgets instead of re-implementing them.
- General theming (buttons, cards, inputs, AppBar) is centralized in `AppTheme`
  (`core/theme/app_theme.dart`); extend it rather than overriding per-screen.
- Prefer theme-aware colors (`Theme.of(context).colorScheme.*`) in reusable widgets so
  dark mode works correctly.

---

## 8. Routing (go_router)

- Central `AuthRouter.router` in `core/routes/app_router.dart`; paths/names centralized
  in `core/routes/route_names.dart`.
- **Always** register new routes in both files (path constant + `GoRoute`).
- Navigate via `context.push(...)` / `context.go(...)` / `context.goNamed(...)`.
- Auth-guard/redirect logic goes in the commented `_guard` stub in `app_router.dart`
  (not yet implemented — leave it commented until auth state is wired up).

---

## 9. Conventions to strictly avoid

- Do **not** create circular imports between features.
- Do **not** put business logic in widgets — it belongs in the Cubit/use case.
- Do **not** use `GlobalKey`/`BuildContext` across async gaps without checking
  `context.mounted`.
- Do **not** leave long public class/methods undocumented when the rest of the file is
  documented (match existing `///` doc style).
- Do **not** add new state-management, DI, or HTTP packages without a strong reason and
  without updating this file.
- Do **not** edit generated files by hand (see §4).
- Do **not** commit `.env` (already gitignored) or real credentials.

---

## 10. Verification checklist before finishing a task

1. Run `dart run build_runner build` if any
   model/data-source/DI file changed.
2. Run `flutter analyze` — **0 errors, 0 warnings** (fix all).
3. Run `dart format lib` to normalize formatting.
4. Run `flutter test` if tests exist.
5. Confirm new routes are registered in both `route_names.dart` and `app_router.dart`.
6. Confirm feature code respects the layer boundaries in §1/§2.
7. Confirm no hard-coded colors/spacing/text styles in new code (§7), and that all
   dimensions use `flutter_screenutil` extensions (`w`/`h`/`r`/`sp`).
