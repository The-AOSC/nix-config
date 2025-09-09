#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/helpers/MiscFunctions.hpp>
#include <hyprland/src/helpers/Monitor.hpp>
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
typedef SWorkspaceIDName (*origGetWorkspaceIDNameFromStringHook)(const std::string& in);

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

            const std::string &info_dim_change = info.substr(info_pos1, info_pos2);
            const int config_dim_size = std::max(std::stoi(config.substr(config_pos1, config_pos2)), 1);
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
        return (*(origGetWorkspaceIDNameFromStringHook)g_pGetWorkspaceIDNameFromStringHook->m_original)(in);
    }
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string HASH = __hyprland_api_get_hash();

    // ALWAYS add this to your plugins. It will prevent random crashes coming from
    // mismatched header versions.
    if (HASH != GIT_COMMIT_HASH) {
        //HyprlandAPI::addNotification(PHANDLE, PLUGIN_NAME " Mismatched headers! Can't proceed.",
        //                             CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
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
        g_pGetWorkspaceIDNameFromStringHook ->hook();
    }

    bool success = true;
    success = success && HyprlandAPI::addConfigValue(PHANDLE, PLUGIN_PREFIX "array_sizes", Hyprlang::STRING{"10"});
    if (!success) {
        HyprlandAPI::addNotification(PHANDLE, PLUGIN_LOG_PREFIX " Failure in initializetion: failed to register dispatchers", CHyprColor(1.0, 0.2, 0.2, 1.0), 5000);
        throw std::runtime_error("[" PLUGIN_NAME "] Dispatchers failed");
    }

    return {PLUGIN_NAME, PLUGIN_DESCRIPTION, PLUGIN_AUTHOR, PLUGIN_VERSION};
}

APICALL EXPORT void PLUGIN_EXIT() {
}
