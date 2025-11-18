#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/helpers/MiscFunctions.hpp>
#include <hyprland/src/helpers/Monitor.hpp>
#include <hyprland/src/managers/animation/DesktopAnimationManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>

#define PLUGIN_NAME "multi-dimensional-workspaces"
#define PLUGIN_SNAME "mdw"
#define PLUGIN_DESCRIPTION "Hyprland plugin that aranges workspaces as a multi-dimensional array"
#define PLUGIN_AUTHOR "The AOSC"
#define PLUGIN_VERSION "1.0"

#define PLUGIN_LOG_PREFIX "[" PLUGIN_NAME "]"
#define PLUGIN_PREFIX "plugin:" PLUGIN_SNAME ":"

inline HANDLE PHANDLE = nullptr;

// Do NOT change this function.
APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

// make a global instance of a hook class for this hook
inline CFunctionHook* g_pGetWorkspaceIDNameFromStringHook = nullptr;
// create a pointer typedef for the function we are hooking.
typedef SWorkspaceIDName (*origGetWorkspaceIDNameFromString)(const std::string& in);

SWorkspaceIDName hkGetWorkspaceIDNameFromString(const std::string& in) {
    if (in.starts_with(PLUGIN_PREFIX)) {
        SWorkspaceIDName result = {WORKSPACE_INVALID, ""};
        static auto* const ARRAY_SIZES = (Hyprlang::STRING const*)HyprlandAPI::getConfigValue(PHANDLE, PLUGIN_PREFIX "array_sizes")->getDataStaticPtr();

        int target = g_pCompositor->m_lastMonitor->activeWorkspaceID();
        const std::string &info = in.substr(((const std::string) PLUGIN_PREFIX).length());
        const std::string &config = *ARRAY_SIZES;
        const std::string &delim = ":";
        size_t info_pos1 = 0;
        size_t config_pos1 = 0;
        size_t info_pos2;
        size_t config_pos2;
        int factor = 1;
        do {
            info_pos2 = info.find(delim, info_pos1);
            config_pos2 = config.find(delim, config_pos1);

            const std::string &info_dim_change = info.substr(info_pos1, info_pos2-info_pos1);
            const int config_dim_size = std::max(std::stoi(config.substr(config_pos1, config_pos2-config_pos1)), 1);
            int current_dim = (((target-1) / factor) % config_dim_size)+1;

            int target_dim;
            if ((info_dim_change[0] == '+') || (info_dim_change[0] == '-')) {
                const auto plusMinusResult = getPlusMinusKeywordResult(info_dim_change, current_dim);
                if (!plusMinusResult.has_value()) {
                    return {WORKSPACE_INVALID};
                }
                target_dim = sc<int>(plusMinusResult.value());
            } else {
                target_dim = std::stoi(info_dim_change);
            }
            target_dim = std::max(std::min(target_dim, config_dim_size), 1);

            target += (target_dim-current_dim) * factor;
            factor *= config_dim_size;

            info_pos1 = info_pos2+delim.length();
            config_pos1 = config_pos2+delim.length();
        } while ((info_pos2 != std::string::npos) && (config_pos2 != std::string::npos));

        result.id = target;
        result.name = std::to_string(result.id);
        return result;
    } else {
        return (*(origGetWorkspaceIDNameFromString)g_pGetWorkspaceIDNameFromStringHook->m_original)(in);
    }
}

std::string anim_style = "";

inline CFunctionHook* g_pChangeWorkspaceHook = nullptr;
typedef void (*origChangeWorkspace)(CMonitor*, const PHLWORKSPACE& pWorkspace, bool internal, bool noMouseMove, bool noFocus);
void hkChangeWorkspace(CMonitor *thisptr, const PHLWORKSPACE& pWorkspace, bool internal, bool noMouseMove, bool noFocus) {
    const auto prev_workspace = thisptr->m_activeWorkspace;
    WORKSPACEID prev_id = (prev_workspace ? prev_workspace->m_id : WORKSPACE_INVALID) - 1;
    WORKSPACEID new_id = (pWorkspace->m_id) - 1;

    static auto* const ARRAY_SIZES = (Hyprlang::STRING const*)HyprlandAPI::getConfigValue(PHANDLE, PLUGIN_PREFIX "array_sizes")->getDataStaticPtr();
    static auto* const ANIMATIONS = (Hyprlang::STRING const*)HyprlandAPI::getConfigValue(PHANDLE, PLUGIN_PREFIX "animations")->getDataStaticPtr();
    const std::string &config = *ARRAY_SIZES;
    const std::string &anim = *ANIMATIONS;
    const std::string &delim = ":";
    const std::string &anim_subdelim = "|";
    size_t config_pos1 = 0;
    size_t anim_pos1 = 0;
    size_t config_pos2;
    size_t anim_pos2;
    int factor = 1;
    do {
        config_pos2 = config.find(delim, config_pos1);
        anim_pos2 = anim.find(delim, anim_pos1);

        const std::string &config_info = config.substr(config_pos1, config_pos2-config_pos1);
        const int config_dim_size = config_info=="" ? 1 : std::max(std::stoi(config_info), 1);

        int delta = ((new_id/factor) % config_dim_size) - ((prev_id/factor) % config_dim_size);
        if (delta) {
            const std::string &anim_info = anim.substr(anim_pos1, anim_pos2-anim_pos1);
            size_t anim_info_pos = anim_info.find(anim_subdelim, 0);
            if (anim_info_pos == std::string::npos) {
                anim_style = anim_info;
            } else {
                if (delta < 0) {
                    anim_style = anim_info.substr(0, anim_info_pos);
                } else {
                    anim_style = anim_info.substr(anim_info_pos+anim_subdelim.length(), std::string::npos);
                }
            }
        }

        factor *= config_dim_size;

        config_pos1 = config_pos2+delim.length();
        anim_pos1 = anim_pos2+delim.length();
    } while (!((config_pos2 == std::string::npos) && (anim_pos2 == std::string::npos)));

    if ((new_id/factor) != (prev_id/factor)) {
        anim_style = "";
    }

    (*(origChangeWorkspace)g_pChangeWorkspaceHook->m_original)(thisptr, pWorkspace, internal, noMouseMove, noFocus);

    anim_style = "";
}

static bool force_workspace_animation = false;

inline CFunctionHook* g_pStartAnimationHook = nullptr;
typedef void (*origStartAnimation)(void*, PHLWORKSPACE ws, CDesktopAnimationManager::eAnimationType type, bool left, bool instant);
void hkStartAnimation(void *thisptr, PHLWORKSPACE ws, CDesktopAnimationManager::eAnimationType type, bool left, bool instant) {
    Hyprutils::Memory::CWeakPointer<Hyprutils::Animation::SAnimationPropertyConfig> conf = ws->m_alpha->getConfig();

    std::string style;
    if (const auto pconfig = conf.lock()) {
        if (const auto pvalues = pconfig->pValues.lock()) {
            style = pvalues->internalStyle;
            if (anim_style != "") {
                pvalues->internalStyle = anim_style;
            }
        }
    }

    if (force_workspace_animation) {
        instant = false;
    }
    (*(origStartAnimation)g_pStartAnimationHook->m_original)(thisptr, ws, type, left, instant);

    if (const auto pconfig = conf.lock()) {
        if (const auto pvalues = pconfig->pValues.lock()) {
            pvalues->internalStyle = style;
        }
    }
}

SDispatchResult focusWorkspaceOnCurrentMonitorFix(std::string args) {
    force_workspace_animation = true;
    auto result = g_pKeybindManager->m_dispatchers["focusworkspaceoncurrentmonitor"](args);
    force_workspace_animation = false;
    for (auto const& w : g_pCompositor->m_windows) {
        w->m_realPosition->warp();
        w->m_realSize->warp();
    }
    return result;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string HASH = __hyprland_api_get_hash();
    const std::string CLIENT_HASH = __hyprland_api_get_client_hash();

    // ALWAYS add this to your plugins. It will prevent random crashes coming from
    // mismatched header versions.
    if (HASH != CLIENT_HASH) {
        HyprlandAPI::addNotification(PHANDLE, PLUGIN_LOG_PREFIX " Mismatched Hyprland version! check logs for details",
                                     CHyprColor(1.0, 0.2, 0.2, 1.0), 5000);
        Debug::log(ERR, PLUGIN_LOG_PREFIX " version mismatch!");
        Debug::log(ERR, PLUGIN_LOG_PREFIX " | hyprgrass was built against: {}", GIT_COMMIT_HASH);
        Debug::log(ERR, PLUGIN_LOG_PREFIX " | actual hyprland version: {}", HASH);
    }

    {
        // create the hook
        static const auto methods = HyprlandAPI::findFunctionsByName(PHANDLE, "getWorkspaceIDNameFromString");
        g_pGetWorkspaceIDNameFromStringHook = HyprlandAPI::createFunctionHook(PHANDLE, methods[0].address, (void*)&hkGetWorkspaceIDNameFromString);
        // init the hook
        g_pGetWorkspaceIDNameFromStringHook->hook();
    }
    {
        // objdump -T /proc/(pgrep Hyprland)/exe | grep changeWorkspace
        static const auto methods = HyprlandAPI::findFunctionsByName(PHANDLE, "_ZN8CMonitor15changeWorkspaceERKN9Hyprutils6Memory14CSharedPointerI10CWorkspaceEEbbb");
        g_pChangeWorkspaceHook = HyprlandAPI::createFunctionHook(PHANDLE, methods[0].address, (void*)&hkChangeWorkspace);
        // init the hook
        g_pChangeWorkspaceHook->hook();
    }
    {
        // create the hook
        // objdump -T /proc/(pgrep Hyprland)/exe | grep startAnimation
        static const auto methods = HyprlandAPI::findFunctionsByName(PHANDLE, "_ZN24CDesktopAnimationManager14startAnimationEN9Hyprutils6Memory14CSharedPointerI10CWorkspaceEENS_14eAnimationTypeEbb");
        g_pStartAnimationHook = HyprlandAPI::createFunctionHook(PHANDLE, methods[0].address, (void*)&hkStartAnimation);
        // init the hook
        g_pStartAnimationHook->hook();
    }

    bool success = true;
    success = success && HyprlandAPI::addConfigValue(PHANDLE, PLUGIN_PREFIX "array_sizes", Hyprlang::STRING{"10"});
    success = success && HyprlandAPI::addConfigValue(PHANDLE, PLUGIN_PREFIX "animations", Hyprlang::STRING{"slide left|slide right"});
    success = success && HyprlandAPI::addDispatcherV2(PHANDLE, PLUGIN_PREFIX "focusworkspaceoncurrentmonitor", focusWorkspaceOnCurrentMonitorFix);
    if (!success) {
        HyprlandAPI::addNotification(PHANDLE, PLUGIN_LOG_PREFIX " Failure in initializetion: failed to register dispatchers", CHyprColor(1.0, 0.2, 0.2, 1.0), 5000);
        throw std::runtime_error("[" PLUGIN_NAME "] Dispatchers failed");
    }

    return {PLUGIN_NAME, PLUGIN_DESCRIPTION, PLUGIN_AUTHOR, PLUGIN_VERSION};
}

APICALL EXPORT void PLUGIN_EXIT() {
}
