#!/usr/bin/env bash
# End-to-end smoke test for ai-dev-kit. Generates disposable fixture projects,
# runs the real pipeline against them, and asserts detection, index output,
# stack-gated rule seeding, auto-update behavior, and idempotency.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export AI_DEV_KIT_HOME="$ROOT"

PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); printf '  ok  %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf ' FAIL %s\n' "$1"; }
check() { # $1=description, $2=command (eval'd)
  if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi
}

export PATH="$BIN:$PATH"   # the dispatcher must resolve THIS checkout's commands

run_pipeline() { # $1=project dir
  (cd "$1" && "$BIN/ai-dev" . >/dev/null 2>&1)
}

# ---------------------------------------------------------------- laravel ---
L="$WORK/laravel"
mkdir -p "$L"/{app/Http/Controllers,app/Models,app/Livewire,app/Filament/Resources,app/Jobs,app/Listeners,app/Providers,database/migrations,routes,tests/Feature,resources/views}
touch "$L/artisan"
cat > "$L/composer.json" <<'EOF'
{"require":{"php":"^8.2","laravel/framework":"^11.0","livewire/livewire":"^3.0","filament/filament":"^3.2","laravel/sanctum":"^4.0"},
 "require-dev":{"pestphp/pest":"^2.0","larastan/larastan":"^2.0","laravel/pint":"^1.0"},
 "autoload":{"psr-4":{"App\\":"app/"}},
 "scripts":{"test":"pest","lint":"pint --test","analyse":"phpstan analyse"}}
EOF
cat > "$L/routes/web.php" <<'EOF'
<?php
use App\Http\Controllers\OrderController;
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
    Route::post(
        '/orders/{order}/refund',
        [OrderController::class, 'refund']
    )->name('orders.refund');
});
Route::controller(OrderController::class)->group(function () {
    Route::get('/track/{code}', 'track');
});
EOF
cat > "$L/app/Http/Controllers/OrderController.php" <<'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\Order;
class OrderController extends Controller
{
    public function index() {}
    public function refund(Order $order) {}
}
EOF
cat > "$L/app/Models/Order.php" <<'EOF'
<?php
namespace App\Models;
class Order extends Model
{
    protected $table = 'orders';
    public function items() { return $this->hasMany(OrderItem::class); }
}
EOF
cat > "$L/app/Models/LatestPost.php" <<'EOF'
<?php
namespace App\Models;
class LatestPost extends Model {}
EOF
cat > "$L/app/Livewire/OrderTable.php" <<'EOF'
<?php
namespace App\Livewire;
use Livewire\Component;
use Livewire\Attributes\Locked;
class OrderTable extends Component
{
    #[Locked]
    public int $orderId;
    public function refund() {}
    public function render() {}
}
EOF
cat > "$L/app/Filament/Resources/OrderResource.php" <<'EOF'
<?php
namespace App\Filament\Resources;
use Filament\Resources\Resource;
use App\Models\Order;
class OrderResource extends Resource
{
    protected static ?string $model = Order::class;
}
EOF
cat > "$L/database/migrations/2024_01_01_000000_create_orders_table.php" <<'EOF'
<?php
return new class extends Migration {
    public function up(): void {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('status');
            $table->timestamps();
        });
    }
};
EOF
cat > "$L/tests/Feature/OrderControllerTest.php" <<'EOF'
<?php
namespace Tests\Feature;
use App\Http\Controllers\OrderController;
class OrderControllerTest extends TestCase {}
EOF

echo "== laravel fixture"
run_pipeline "$L"
IDX="$L/.ai/project-index"
check "stack detects laravel+livewire+filament" "grep -q 'Laravel, Livewire, Filament' '$IDX/PROJECT_MAP.md'"
check "quality gates listed"                    "grep -q 'composer test' '$IDX/PROJECT_MAP.md'"
check "group prefix + name resolved"            "grep -q 'admin/orders/{order}/refund' '$IDX/ROUTES.md' && grep -q 'admin.orders.refund' '$IDX/ROUTES.md'"
check "controller-group method resolved"        "grep -q 'OrderController@track' '$IDX/ROUTES.md'"
check "livewire entry point row"                "grep -q 'LIVEWIRE' '$IDX/ROUTES.md'"
check "filament resource row with model"        "grep -q 'FILAMENT | OrderResource' '$IDX/ROUTES.md' || grep -q 'FILAMENT' '$IDX/ROUTES.md'"
check "SCHEMA.md folded from migrations"        "grep -q 'status:string' '$IDX/SCHEMA.md'"
check "LatestPost is model not test"            "grep '\"app/Models/LatestPost.php\"' '$IDX/SYMBOLS.jsonl' | grep -q '\"responsibility\":\"model\"'"
check "Locked attr captured"                    "grep -q '\"attrs\":\\[\"Locked\"\\]' '$IDX/SYMBOLS.jsonl'"
check "tested_by mapping"                       "grep -q 'tested_by' '$IDX/SYMBOLS.jsonl'"
check "kit-version stamped"                     "test -f '$L/.ai/kit-version'"
check "adapters carry managed blocks"           "grep -q 'ai-dev-kit:begin' '$L/AGENTS.md' && grep -q 'ai-dev-kit:begin' '$L/CLAUDE.md'"
check "livewire rules seeded"                   "test -f '$L/.ai/rules/17-livewire/10-livewire-security.mdc'"
check "filament rules seeded"                   "test -f '$L/.ai/rules/18-filament/10-filament-authorization-tenancy.mdc'"
check "sanctum rule seeded, passport not"       "test -f '$L/.ai/rules/30-api/10-sanctum.mdc' && test ! -f '$L/.ai/rules/30-api/20-passport.mdc'"
check "pest variant seeded, phpunit not"        "test -f '$L/.ai/rules/60-testing/10-pest.mdc' && test ! -f '$L/.ai/rules/60-testing/20-phpunit.mdc'"
check "no wordpress rules"                      "test ! -d '$L/.ai/rules/25-wordpress'"
check "no inertia rules (not detected)"         "test ! -d '$L/.ai/rules/15-inertia-react'"
check "cursor rules is a symlink to .ai/rules"  "test -L '$L/.cursor/rules' && test -f '$L/.cursor/rules/00-core/project-navigation.mdc'"
check "adapters point at the shared rule set"   "grep -q '.ai/rules/' '$L/AGENTS.md' && grep -q '.ai/rules/' '$L/CLAUDE.md'"
check "query symbol with line+owner"            "(cd '$L' && python3 '$BIN/ai-dev-query' symbol refund | grep -q 'OrderController)')"
check "query table columns"                     "(cd '$L' && python3 '$BIN/ai-dev-query' table orders | grep -q 'status:string')"

# idempotency: second run writes nothing
sleep 1.1
MARKER="$WORK/marker"; touch "$MARKER"
run_pipeline "$L"
if [ -z "$(find "$L" -type f -newer "$MARKER" | head -1)" ]; then
  ok "second run fully idempotent (zero writes)"
else
  bad "second run wrote: $(find "$L" -type f -newer "$MARKER" | head -3 | tr '\n' ' ')"
fi

# customized rule survives update
echo "PROJECT CUSTOM" >> "$L/.ai/rules/40-security/00-security.mdc"
(cd "$L" && "$BIN/ai-dev" update . >/dev/null 2>&1)
check "customized rule kept on update"          "grep -q 'PROJECT CUSTOM' '$L/.ai/rules/40-security/00-security.mdc'"

# user content outside managed block survives
printf '\nMY PROJECT NOTES\n' >> "$L/AGENTS.md"
run_pipeline "$L"
check "user content outside block survives"     "grep -q 'MY PROJECT NOTES' '$L/AGENTS.md'"

# no-downgrade: newer stamp is preserved
echo "9.9.9" > "$L/.ai/kit-version"
run_pipeline "$L"
check "newer stamp never downgraded"            "grep -q '9.9.9' '$L/.ai/kit-version'"
echo "$(cat "$ROOT/VERSION")" > "$L/.ai/kit-version"

# spec scaffolding
(cd "$L" && "$BIN/ai-dev" spec "Refund Flow" >/dev/null 2>&1)
check "spec-lite scaffolded with slug+number"   "test -f '$L/.ai/specs/001-refund-flow/tasks.md'"

# ---------------------------------------------------------------- wp plugin -
W="$WORK/wp-plugin"
mkdir -p "$W/includes"
cat > "$W/my-plugin.php" <<'EOF'
<?php
/**
 * Plugin Name: My Shop Extras
 * Version: 1.0.0
 */
add_action('init', 'mse_register');
add_shortcode('mse_widget', 'mse_widget_cb');
register_rest_route('mse/v1', '/orders', ['methods' => 'GET', 'callback' => 'mse_orders']);
register_rest_route('mse/v1', '/status', ['methods' => 'GET', 'callback' => 'mse_status', 'permission_callback' => '__return_true']);
register_post_type('mse_deal', ['public' => true]);
register_activation_hook(__FILE__, 'mse_activate');
EOF

echo "== wp-plugin fixture"
run_pipeline "$W"
IDX="$W/.ai/project-index"
check "wp plugin subtype detected"              "grep -q '\"type\": \"plugin\"' '$IDX/manifest.json'"
check "HOOKS.md emitted"                        "test -f '$IDX/HOOKS.md'"
check "REST callback resolved (not methods)"    "grep -q 'mse_orders' '$IDX/HOOKS.md' && ! grep -q '| GET |' '$IDX/HOOKS.md'"
check "missing permission_callback flagged"     "grep -q 'NO permission_callback' '$IDX/HOOKS.md'"
check "permission_callback present not flagged" "grep 'mse_status' '$IDX/HOOKS.md' | grep -vq 'NO permission_callback'"
check "CPT + lifecycle rows"                    "grep -q 'CPT' '$IDX/HOOKS.md' && grep -q 'ACTIVATION' '$IDX/HOOKS.md'"
check "wordpress rules seeded"                  "test -f '$W/.ai/rules/25-wordpress/10-wp-security.mdc'"
check "zero laravel rules"                      "test ! -d '$W/.ai/rules/10-laravel' && test ! -d '$W/.ai/rules/16-blade' && test ! -d '$W/.ai/rules/50-performance'"
check "no woocommerce rules (not detected)"     "test ! -d '$W/.ai/rules/26-woocommerce'"
check "no empty category dirs"                  "test -z \"\$(find '$W/.ai/rules' -type d -empty)\""
check "query hook finds unprotected REST"       "(cd '$W' && python3 '$BIN/ai-dev-query' hook 'NO permission' | grep -q 'mse/v1/orders')"

# ---------------------------------------------------------------- composer --
C="$WORK/composer-lib"
mkdir -p "$C/src/Billing" "$C/tests"
cat > "$C/composer.json" <<'EOF'
{"require":{"php":"^8.3","symfony/framework-bundle":"^7.0"},"require-dev":{"phpunit/phpunit":"^11.0","phpstan/phpstan":"^1.11"},"autoload":{"psr-4":{"App\\":"src/"}},"scripts":{"test":"phpunit"}}
EOF
cat > "$C/src/Billing/InvoiceCalculator.php" <<'EOF'
<?php
namespace App\Billing;
final class InvoiceCalculator
{
    public function total(): int { return 0; }
}
EOF

echo "== composer/symfony fixture"
run_pipeline "$C"
check "symfony detected"                        "grep -q '\"symfony\": true' '$C/.ai/project-index/manifest.json'"
check "psr-4 domain from src/"                  "(cd '$C' && python3 '$BIN/ai-dev-query' map | grep -q 'Billing')"
check "generic php rules seeded"                "test -f '$C/.ai/rules/11-php/00-modern-php.mdc' && test -f '$C/.ai/rules/12-php-tooling/10-static-analysis.mdc'"
check "non-eloquent db rule, no laravel db"     "test -f '$C/.ai/rules/20-database/30-non-eloquent-database.mdc' && test ! -f '$C/.ai/rules/20-database/00-query-performance.mdc'"
check "phpunit variant seeded"                  "test -f '$C/.ai/rules/60-testing/20-phpunit.mdc' && test ! -f '$C/.ai/rules/60-testing/10-pest.mdc'"
check "no laravel/wp/livewire rules"            "test ! -d '$C/.ai/rules/10-laravel' && test ! -d '$C/.ai/rules/25-wordpress' && test ! -d '$C/.ai/rules/17-livewire'"

# ------------------------------------------------------- declaration layer --
D="$WORK/decl"
mkdir -p "$D/app/Services"
touch "$D/artisan"
cat > "$D/app/Services/RefundService.php" <<'EOF'
<?php
namespace App\Services;

class RefundService
{
    /**
     * Refunds an order and emits the OrderRefunded event.
     */
    public function refund(Order $order, ?int $cents = null, bool $notify = true): RefundResult
    {
        $this->assertRefundable($order);
        $label = "a string with a brace } and a semicolon ;";
        return new RefundResult();
    }

    private function assertRefundable(Order $order): void
    {
        // an unbalanced brace inside a comment: {
    }

    abstract public function describe(): string;
}
EOF

echo "== declaration layer (signatures, ranges, calls)"
run_pipeline "$D"
Q="python3 $BIN/ai-dev-query --project $D"
check "full signature captured"                 "$Q symbol refund | grep -q 'refund'"
check "api lists signature + range + doc"       "$Q api RefundService | grep -q '?int \$cents = null' && $Q api RefundService | grep -q 'Refunds an order'"
check "api hides private methods"               "! $Q api RefundService | grep -q assertRefundable"
check "abstract method has no range"            "$Q api RefundService | grep -q 'describe(): string'"
# refund() spans lines 9-14; the `}` inside the string literal on line 12 and
# the `{` inside the comment must not extend or truncate that range.
check "masking survives brace in string"        "grep -q '\"end\":14' '$D/.ai/project-index/SYMBOLS.jsonl'"
check "masking survives brace in comment"       "grep -q '\"name\":\"assertRefundable\",\"line\":15,\"end\":19' '$D/.ai/project-index/SYMBOLS.jsonl' || grep -q '\"assertRefundable\"' '$D/.ai/project-index/SYMBOLS.jsonl'"
check "call edges recorded"                     "grep -q 'RefundService::assertRefundable' '$D/.ai/project-index/SYMBOLS.jsonl'"
check "callers resolves reverse edge"           "$Q callers assertRefundable | grep -q RefundService.php"
check "snippet returns only the symbol range"   "test \"\$($Q snippet RefundService::refund | wc -l)\" -lt 18"

# The token claim only means something on a realistically sized class.
python3 - "$D/app/Services/BigService.php" <<'PYEOF'
import sys
lines = ["<?php", "namespace App\\Services;", "", "class BigService", "{"]
for i in range(60):
    lines += [
        f"    /**",
        f"     * Operation number {i} in the billing workflow.",
        f"     */",
        f"    public function operation{i}(int $id, ?string $note = null): bool",
        "    {",
        f"        $this->log('operation{i}');",
        "        return true;",
        "    }",
        "",
    ]
lines.append("}")
open(sys.argv[1], "w").write("\n".join(lines) + "\n")
PYEOF
run_pipeline "$D"
BIG_BYTES=$(wc -c < "$D/app/Services/BigService.php")
SNIP_BYTES=$($Q snippet 'BigService::operation42' | wc -c)
API_BYTES=$($Q api BigService | wc -c)
check "snippet is a small fraction of a big file" "test $SNIP_BYTES -lt $((BIG_BYTES / 8))"
printf '      big class %s B (~%s tok) | read_symbol %s B (~%s tok) | list_api %s B (~%s tok)\n' \
  "$BIG_BYTES" "$((BIG_BYTES/4))" "$SNIP_BYTES" "$((SNIP_BYTES/4))" "$API_BYTES" "$((API_BYTES/4))"

# ---------------------------------------------------------- editor adapters -
echo "== editor adapters"
E="$WORK/editors"
mkdir -p "$E/.windsurf" "$E/.kilocode"
printf 'MY CLINE RULES\n' > "$E/.clinerules"
(cd "$E" && "$BIN/ai-dev-init" . --update >/dev/null)
check "detected editor adapters seeded"         "test -f '$E/.windsurf/rules/ai-dev-kit.md' && test -f '$E/.kilocode/rules/00-ai-dev-kit.md'"
check "undetected editors left alone"           "test ! -e '$E/.roo' && test ! -e '$E/.trae' && test ! -e '$E/GEMINI.md'"
check "windsurf adapter keeps frontmatter first" "head -1 '$E/.windsurf/rules/ai-dev-kit.md' | grep -q -- '---'"
check "single-file .clinerules kept as a file"  "test -f '$E/.clinerules' && grep -q 'MY CLINE RULES' '$E/.clinerules' && grep -q 'ai-dev-kit:begin' '$E/.clinerules'"
check "adapters point at the shared rule set"   "grep -q '.ai/rules/' '$E/.windsurf/rules/ai-dev-kit.md'"

(cd "$E" && "$BIN/ai-dev-init" . --editors=kilo,zed,bogus >/dev/null 2>&1)
check "explicit editors seeded"                 "test -f '$E/.kilo/rules/00-ai-dev-kit.md' && test -f '$E/.rules'"
check "kilo.jsonc wires the rules glob"         "grep -q '.kilo/rules/\*.md' '$E/kilo.jsonc'"
check "choice remembered in .ai/editors"        "grep -qx 'kilo' '$E/.ai/editors' && grep -qx 'zed' '$E/.ai/editors' && ! grep -qx 'bogus' '$E/.ai/editors'"

printf '\nMY OWN NOTE\n' >> "$E/.kilo/rules/00-ai-dev-kit.md"
(cd "$E" && "$BIN/ai-dev-init" . --update >/dev/null)
check "adapter customization survives update"   "grep -q 'MY OWN NOTE' '$E/.kilo/rules/00-ai-dev-kit.md' && test \"\$(grep -c 'ai-dev-kit:begin' '$E/.kilo/rules/00-ai-dev-kit.md')\" -eq 1"
check "--list-editors lists kilo and windsurf"  "'$BIN/ai-dev-init' --list-editors | grep -q kilo && '$BIN/ai-dev-init' --list-editors | grep -q windsurf"

# ------------------------------------------------------------- MCP server ---
echo "== MCP server"
MCP_OUT="$WORK/mcp.out"
printf '%s\n' \
 '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{}}}' \
 '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
 '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
 '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_api","arguments":{"target":"RefundService"}}}' \
 '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"bogus","arguments":{}}}' \
 | python3 "$BIN/ai-dev-mcp" --project "$D" > "$MCP_OUT" 2>/dev/null || true
check "initialize returns protocol + version"   "grep -q '\"protocolVersion\": \"2024-11-05\"' '$MCP_OUT'"
check "notification produces no response"       "test \"\$(wc -l < '$MCP_OUT')\" -eq 4"
check "tools/list advertises the fixed set"     "grep -q 'read_symbol' '$MCP_OUT' && grep -q 'find_callers' '$MCP_OUT'"
check "tools/call returns index content"        "grep -q 'Refunds an order' '$MCP_OUT'"
check "unknown tool returns JSON-RPC error"     "grep -q '\"code\": -32602' '$MCP_OUT'"
check "server never writes to the project"      "test ! -e '$D/.ai/project-index/.mcp' && test -z \"\$(find '$D' -newer '$MCP_OUT' -type f 2>/dev/null)\""

# --------------------------------------------------------- legacy migration -
if git -C "$ROOT" rev-parse --verify c3d15ac >/dev/null 2>&1; then
  G="$WORK/legacy"
  mkdir -p "$G"
  git -C "$ROOT" show c3d15ac:bin/ai-dev-init > "$WORK/old-init.sh" && chmod +x "$WORK/old-init.sh"
  (cd "$G" && "$WORK/old-init.sh" . >/dev/null)
  echo "USER EDIT" >> "$G/CLAUDE.md"
  echo "== legacy (pre-1.4) migration fixture"
  run_pipeline "$G"
  check "pristine adapter replaced with block"  "grep -q 'ai-dev-kit:begin' '$G/AGENTS.md' && ! grep -q 'USER EDIT' '$G/AGENTS.md'"
  check "edited adapter keeps user content"     "grep -q 'USER EDIT' '$G/CLAUDE.md' && grep -q 'ai-dev-kit:begin' '$G/CLAUDE.md'"
  check "legacy index-first mdc removed"        "test ! -f '$G/.ai/rules/00-project-index-first.mdc'"
else
  echo "== legacy migration fixture skipped (no git history)"
fi

# --------------------------------------------------------------- kit checks -
echo "== kit self-checks"
check "always-on template budget"               "python3 '$ROOT/tools/measure-context.py' --templates"
check "kit lint clean"                          "python3 '$ROOT/tools/lint_kit.py'"

echo
echo "passed: $PASS, failed: $FAIL"
[ "$FAIL" -eq 0 ]
