# LOGIC DESIGN PROJECT- Template Matching SoC
CO3091 Logic Design Project Course from HCMUT.
Project using a FPGA Board for Template Matching. 
__________________________________________________
# Block Diagram for the project

## 🧠 Template Matching Core (Simulation Version)

```mermaid
flowchart TD

    %% ==========================
    %% Input Section
    %% ==========================
    subgraph Input["Input"]
        A[/"Grayscale Image"/]
        B[/"Template Image"/]
    end

    %% ==========================
    %% Control Unit
    %% ==========================
    subgraph Control["Control Unit (FSM)"]
        C[["Scanning and iteration"]]
        D[["Sends pixel pairs to SAD core"]]
        G[["Compare SAD results and track minimum"]]
        H[["Stores (x, y) of best match"]]
    end

    %% ==========================
    %% Processing Core
    %% ==========================
    subgraph Core["SAD Compute Module"]
        E{"Computes Sum of Absolute Differences and outputs SAD value for each position"}
    end

    %% ==========================
    %% Output Section
    %% ==========================
    subgraph Output["Output (Simulation)"]
        F[/"Displays best (x, y) and SAD result in Vivado Tcl console"/]
    end

    %% ==========================
    %% Connections
    %% ==========================
    Control ==> Core ==> Control
    Input --"Stored in Verilog Variables"--> Control --"Best position found"--> Output
```
## ✅ Full Advanced Project

```mermaid
flowchart LR

    %% === MAIN SYSTEM ===
    subgraph SOC["Arty Z7 FPGA SoC"]

        %% --- Dual RISC-V Cores ---
        subgraph RISCV["Dual RISC-V Cores"]
            R2["using PicoRV32 / Ibex"]
            R0[["Core 0: System Control"]]
            R1[["Core 1: Image Processing Control"]]
        end

        %% --- Memory ---
        subgraph MEM["On-Chip Memories"]
            M1[("Instruction & Data Memory")]
            M2[("Shared BRAM (Frame Buffers)")]
            M3[("Template & Image Storage")]
        end
        RISCV <--> MEM

        %% --- Camera ---
        subgraph CAM["Camera Interface"]
            C1[/"Captures grayscale frames"/]
            C2[/"Sends pixel stream to BRAM"/]
        end
        CAM --> MEM

        %% --- Compute ---
        subgraph ACC["Compute Module"]
            A1{"Computes SAD between image & template"}
            A2("Outputs best (x,y) and SAD score")
        end

        %% --- FSM Control ---
        subgraph CTRL["Control Unit"]
            F1[["Initiates matching process"]]
            F2[["Coordinates DMA / memory ops"]]
            F3[["Communicates with RISC-V cores"]]
        end
        CTRL <--> ACC
        CTRL <--> MEM
        RISCV <--> CTRL

        %% --- Output Storage ---
        subgraph RESBUF["Result Buffer / Registers"]
            RB1[("Stores best match coordinates")]
            RB2[("Accessible by RISC-V & HDMI unit")]
        end
        ACC --> RESBUF

        %% --- Output Interfaces ---
        subgraph OUT["Output Interfaces"]
            O1[/"UART → send results to PC / Vivado Tcl"/]
            O2[/"HDMI → visualize detection box"/]
        end
        RESBUF --> OUT

        %% --- HDMI Display Controller ---
        subgraph HDMI["HDMI Display Controller"]
            H1[/"Reads frame from memory"/]
            H2[/"Overlays detected template position"/]
            H3[/"Outputs to monitor"/]
        end
        MEM --> HDMI
        RESBUF --> HDMI

        %% --- ASIC Implementation ---
        subgraph ASIC["ASIC Implementation"]
            AS1[["Implemented on ASAP7 PDK via OpenLane"]]
            AS2[["Includes SAD Core + Control Unit"]]
            AS3[["Verilog → GDSII flow"]]
        end
        ACC --> ASIC
        CTRL --> ASIC

    end

```
