allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect build directory for the root and app project to the root 'build' folder.
// This matches Flutter's CLI expectations.
val newBuildDir: Directory = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Only redirect build directory for projects on the SAME DRIVE as the root project.
    // This prevents "different roots" errors when plugins are in a C:\ Pub cache
    // while the project is on E:\.
    val rootDrive = rootProject.projectDir.absolutePath.substring(0, 3)
    if (project.projectDir.absolutePath.startsWith(rootDrive)) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
