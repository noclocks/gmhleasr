# Images



## Naming Conventions

### General Recommendations

1.  **Consistency**: Use a consistent naming convention across all files. This includes consistent use of separators (e.g., hyphens), lowercase letters, and format.
2.  **Descriptive and Informative**: The name should provide enough information about the image without being excessively long.
3.  **Scalability**: Ensure the naming convention can accommodate future growth and new types of images without requiring significant changes.
4.  **Avoid Special Characters**: Stick to alphanumeric characters and hyphens. Avoid spaces, underscores, and special characters.
5.  **Readability**: The name should be easy to read and understand at a glance.

### Recommended Naming Convention

The following convention includes essential information while maintaining clarity and brevity:

```plaintext
{company}-{type}-{description}-{color}-{feature}-{dimensions}.{extension}
```

where,

- **company** is `noclocks`
- **type** is one of `logo`, `icon`, `symbol`, `wordmark`, `brandmark`, `badge`, `thumbnail`, or `favicon`
- **description**  is a short and sweet description im the image's content and purpose. It should use keywords that are meaningful and consistent depending on the context. This is an optional portion of the file name.
- **color** is the primary, foreground/content color or color scheme utilized by the image. At No Clocks, we only use the following colors names `black`, `white`, `dark`, `light`, `clear`, `transparent`, `full`/`fullcolor`, `mono`/`monochrome`, `multi`/`multicolor`, `gold`, `grey`/`gray`, `red`, `darkred`, `green`, `darkgreen`, `blue`, `darkblue`.
- **feature** is the specific feature of the image such as `circular`, `texturized`, `transparent`, `resized`, etc.
- **extension** is the actual file extension and file format used by the image file (`png`, `svg`, `jpg`/`jpeg`, `gif`, `bmp`, `ico`, `webp`, `avif`, `heic`, `tiff`, `pdf`, etc.)

### Components Explained

1.  **Company**: The name or abbreviation of your company. Ensures branding and ownership.
2.  **Type**: The type of image, such as logo, icon, banner, etc.
3.  **Description**: A brief description of the image content or purpose. Use keywords that are meaningful within your context.
4.  **Color**: The primary color or color scheme of the image.
5.  **Feature**: Any specific feature of the image, such as circular, texturized, transparent, etc.
6.  **Dimensions**: The dimensions of the image in pixels, formatted as `{width}x{height}`.
7.  **Extension**: The file format extension, such as jpg, png, svg, etc.

### Example Naming

1.  **Logo**: `noclocks-logo-primary-black-circular-500x500.png`
2.  **Icon**: `noclocks-icon-settings-gray-50x50.svg`
3.  **Banner**: `noclocks-banner-summer-sale-red-1200x300.jpg`
4.  **Background**: `noclocks-background-office-white-blurred-1920x1080.jpg`

### Rules to Keep in Mind

1.  **File Extension Rules**:
    -   **`.ico`**: This file is an icon and most likely used as a favicon. Therefore, its *type* should be set to `icon` unless it is already set as `logo`, in which case set the `feature` as `favicon`.
    -   **`.svg`**: Do not include dimensions in the filename for SVG files as they are vector images and scalable.
2.  **Description**:
    -   Always use a brief but descriptive keyword for the *description* part to identify the purpose or content of the image.
    -   Avoid using general terms like `image`, `photo`, etc. Instead, use specific terms related to the content or use case.
3.  **Color**:
    -   Use a consistent color naming scheme. For example, use `blue` instead of `blu`, `lightblue`, etc.
    -   If the image has a transparent background, include `transparent` as part of the *feature*.
4.  **Feature**:
    -   Use hyphens to separate multiple features.
    -   Common features include `circular`, `texturized`, `transparent`, `favicon`, etc.
    -   For logos and icons, include `primary`, `secondary`, etc., if applicable.
5.  **Dimensions**:
    -   For non-SVG images, include dimensions as `{width}x{height}`.
    -   If the image is a standard size for web use (e.g., `favicon`, `thumbnail`), include the standard term in the *feature* and avoid repeating dimensions.
6.  **Separators**:
    -   Use hyphens (`-`) as separators between different components of the filename.
    -   Avoid underscores (`_`), spaces, or special characters.

## PowerShell Implentation

```powershell
using namespace System.Drawing

Enum ImgExt {
    jpg
    jpeg
    png
    gif
    bmp
    tiff
    ico
    svg
    webp
    heic
    heif
    avif
}

Enum ImgType {
    logo
    icon
    banner
    background
}

Function Get-ImageDims {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ImagePath
    )

    Begin {
        Add-Type -AssemblyName System.Drawing
        $ImagePath = Resolve-Path $ImagePath
    }

    Process {
        try {
            $image = [System.Drawing.Image]::FromFile($ImagePath)
            $dimensions = @{
                Width  = $image.Width
                Height = $image.Height
            }
            $image.Dispose()
            return $dimensions
        } catch {
            Write-Error "An error occurred while reading the image: $_"
        }
    }
}

function Get-ImgType {
    param (
        [string]$Extension,
        [string]$CurrentType
    )
    switch ($Extension.ToLower()) {
        'ico' { return $CurrentType -eq 'logo' ? 'logo' : 'icon' }
        default { return $CurrentType }
    }
}

function Get-ImgFeature {
    param (
        [string]$FileName,
        [string]$Extension,
        [string]$CurrentType
    )
    $features = @()
    if ($FileName -match 'circular') { $features += 'circular' }
    if ($FileName -match 'texturized') { $features += 'texturized' }
    if ($Extension.ToLower() -eq 'ico' -and $CurrentType -eq 'logo') { $features += 'favicon' }
    return $features -join '-'
}

function Get-ImageFileName {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string[]]$ImagePath,

        [Parameter(Mandatory = $false)]
        [string]$Company = "noclocks",

        [Parameter(Mandatory = $false)]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$Color,

        [Parameter(Mandatory = $false)]
        [string]$Feature,

        [Parameter(Mandatory = $false)]
        [switch]$Rename,

        [Parameter(Mandatory = $false)]
        [switch]$Backup
    )

    Begin {
        if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Image').Type) {
            Add-Type -AssemblyName System.Drawing
        }
    }

    Process {
        foreach ($path in $ImagePath) {
            $resolvedPath = Resolve-Path $path
            $extension = [System.IO.Path]::GetExtension($resolvedPath).TrimStart('.')
            if (-not [Enum]::IsDefined([ImgExt], $extension)) {
                Write-Error "Invalid file extension: $extension"
                continue
            }

            try {
                if (-not $Type) {
                    $Type = Get-ImgType -Extension $extension -CurrentType $Type
                }

                if ($extension -ne 'svg') {
                    $dims = Get-ImageDims -ImagePath $resolvedPath
                    $width = $dims.Width
                    $height = $dims.Height
                    $dimsString = "${width}x${height}"
                } else {
                    $dimsString = ""
                }

                $currentFileName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath)

                if (-not $Feature) {
                    $Feature = Get-ImgFeature -FileName $currentFileName -Extension $extension -CurrentType $Type
                }

                $nameParts = $currentFileName -split '-'
                $nameParts = $nameParts | Where-Object { $_ -notmatch '^\d+x\d+$' }

                if ($Company -and $nameParts -notcontains $Company) { $nameParts += $Company }
                if ($Type -and $nameParts -notcontains $Type) { $nameParts += $Type }
                if ($Description -and $nameParts -notcontains $Description) { $nameParts += $Description }
                if ($Color -and $nameParts -notcontains $Color) { $nameParts += $Color }
                if ($Feature -and $nameParts -notcontains $Feature) { $nameParts += $Feature }
                if ($dimsString -and ($nameParts -notcontains $dimsString)) { $nameParts += "${dimsString}px" }

                $newFileName = ($nameParts -join '-') + ".$extension"

                $directory = [System.IO.Path]::GetDirectoryName($resolvedPath)
                $newFilePath = Join-Path -Path $directory -ChildPath $newFileName

                if ($Rename) {
                    if ($Backup) {
                        $backupPath = Join-Path -Path $directory -ChildPath ("backup-" + [System.IO.Path]::GetFileName($resolvedPath))
                        Copy-Item -Path $resolvedPath -Destination $backupPath
                    }

                    Rename-Item -Path $resolvedPath -NewName $newFilePath
                    Write-Host "Renamed '$resolvedPath' to '$newFilePath'" -ForegroundColor Green
                } else {
                    Write-Host "New file name: '$newFilePath'" -ForegroundColor Green
                }

                $Out = [PSCustomObject]@{
                    OriginalFilePath = $resolvedPath
                    NewFilePath      = $newFilePath
                }

                Write-Output $Out
            } catch {
                Write-Error "An error occurred while processing the image: $_"
            }
        }
    }
}

# Example usage to get the new file name without renaming
Get-ImageFileName -ImagePath "C:\path\to\image.jpg" -Type "logo" -Description "primary" -Color "blue" -Feature "circular"

# Example usage to rename the file
Get-ImageFileName -ImagePath "C:\path\to\image1.jpg","C:\path\to\image2.jpg" -Type "icon" -Description "settings" -Color "gray" -Feature "texturized" -Rename
```