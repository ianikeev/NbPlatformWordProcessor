#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    char appDir[MAX_PATH];
    char javaExe[MAX_PATH];
    char appExe[MAX_PATH];
    char commandLine[2048];
    
    // Get the directory where the launcher is located
    GetModuleFileName(NULL, appDir, MAX_PATH);
    
    // Extract directory path
    char* lastBackslash = strrchr(appDir, '\\');
    if (lastBackslash) {
        *lastBackslash = '\0';
    }
    
    // Construct paths
    snprintf(javaExe, sizeof(javaExe), "%s\\..\\jre\\bin\\javaw.exe", appDir);
    snprintf(appExe, sizeof(appExe), "%s\\wordprocessor64.exe", appDir);
    
    // Check if the main application executable exists
    if (GetFileAttributes(appExe) == INVALID_FILE_ATTRIBUTES) {
        MessageBox(NULL, 
            "Main application executable not found.\n\n"
            "File not found:\n" 
            "wordprocessor64.exe\n\n"
            "The installation may be corrupted.", 
            "Application Error", 
            MB_ICONERROR | MB_OK);
        return 1;
    }
    
    // Check if bundled JRE exists
    if (GetFileAttributes(javaExe) != INVALID_FILE_ATTRIBUTES) {
        // Use bundled JRE
        snprintf(commandLine, sizeof(commandLine), "\"%s\" -jar \"%s\"", javaExe, appExe);
    } else {
        // Use system Java
        snprintf(commandLine, sizeof(commandLine), "javaw.exe -jar \"%s\"", appExe);
    }
    
    // Prepare startup info
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));
    
    // Start the application
    BOOL success = CreateProcess(
        NULL,           // No module name (use command line)
        commandLine,    // Command line
        NULL,           // Process handle not inheritable
        NULL,           // Thread handle not inheritable
        FALSE,          // Set handle inheritance to FALSE
        0,              // No creation flags
        NULL,           // Use parent's environment block
        NULL,           // Use parent's starting directory
        &si,            // Pointer to STARTUPINFO structure
        &pi             // Pointer to PROCESS_INFORMATION structure
    );
    
    if (!success) {
        DWORD error = GetLastError();
        char errorMsg[512];
        
        if (error == ERROR_FILE_NOT_FOUND) {
            snprintf(errorMsg, sizeof(errorMsg),
                "Java Runtime Environment not found.\n\n"
                "This application requires Java to run.\n\n"
                "Please install Java from:\n"
                "https://www.java.com/download\n\n"
                "Error code: %lu", error);
        } else {
            snprintf(errorMsg, sizeof(errorMsg),
                "Failed to start application.\n\n"
                "Command: %s\n\n"
                "Error code: %lu", commandLine, error);
        }
        
        MessageBox(NULL, errorMsg, "Application Error", MB_ICONERROR | MB_OK);
        return 1;
    }
    
    // Close process and thread handles
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    
    return 0;
}