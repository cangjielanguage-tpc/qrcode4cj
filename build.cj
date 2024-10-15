import std.fs.*
import std.process.*

// Case of pre/post codes for 'cjpm build'.
/* called before `cjpm build`
 * Success: return 0
 * Error: return any number except 0
 */
func stagePostBuild(): Int64 {
    // process before "cjpm build"
    copy(Path(".${Path.Separator}image"), to: Path(".${Path.Separator}target${Path.Separator}release${Path.Separator}image"), overwrite: true)
    0
}

main(): Int64 {
    match (Process.current.arguments[0]) {
        // Add operation here with format: "pre-"/"post-" + optionName
        case "post-build" => stagePostBuild()
        case _ => 0
    }
}