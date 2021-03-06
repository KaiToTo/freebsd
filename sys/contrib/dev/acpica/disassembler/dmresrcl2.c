/*******************************************************************************
 *
 * Module Name: dmresrcl2.c - "Large" Resource Descriptor disassembly (#2)
 *
 ******************************************************************************/

/*
 * Copyright (C) 2000 - 2012, Intel Corp.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions, and the following disclaimer,
 *    without modification.
 * 2. Redistributions in binary form must reproduce at minimum a disclaimer
 *    substantially similar to the "NO WARRANTY" disclaimer below
 *    ("Disclaimer") and any redistribution must be conditioned upon
 *    including a substantially similar Disclaimer requirement for further
 *    binary redistribution.
 * 3. Neither the names of the above-listed copyright holders nor the names
 *    of any contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.
 *
 * NO WARRANTY
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 */


#include <contrib/dev/acpica/include/acpi.h>
#include <contrib/dev/acpica/include/accommon.h>
#include <contrib/dev/acpica/include/acdisasm.h>


#ifdef ACPI_DISASSEMBLER

#define _COMPONENT          ACPI_CA_DEBUGGER
        ACPI_MODULE_NAME    ("dbresrcl2")

/* Local prototypes */

static void
AcpiDmI2cSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level);

static void
AcpiDmSpiSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level);

static void
AcpiDmUartSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level);

static void
AcpiDmGpioCommon (
    AML_RESOURCE            *Resource,
    UINT32                  Level);

static void
AcpiDmDumpRawDataBuffer (
    UINT8                   *Buffer,
    UINT32                  Length,
    UINT32                  Level);


/* Dispatch table for the serial bus descriptors */

static ACPI_RESOURCE_HANDLER        SerialBusResourceDispatch [] =
{
    NULL,
    AcpiDmI2cSerialBusDescriptor,
    AcpiDmSpiSerialBusDescriptor,
    AcpiDmUartSerialBusDescriptor
};


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmDumpRawDataBuffer
 *
 * PARAMETERS:  Buffer              - Pointer to the data bytes
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Dump a data buffer as a RawDataBuffer() object. Used for
 *              vendor data bytes.
 *
 ******************************************************************************/

static void
AcpiDmDumpRawDataBuffer (
    UINT8                   *Buffer,
    UINT32                  Length,
    UINT32                  Level)
{
    UINT32                  Index;
    UINT32                  i;
    UINT32                  j;


    if (!Length)
    {
        return;
    }

    AcpiOsPrintf ("RawDataBuffer (0x%.2X)  // Vendor Data", Length);

    AcpiOsPrintf ("\n");
    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("{\n");
    AcpiDmIndent (Level + 2);

    for (i = 0; i < Length;)
    {
        for (j = 0; j < 8; j++)
        {
            Index = i + j;
            if (Index >= Length)
            {
                goto Finish;
            }

            AcpiOsPrintf ("0x%2.2X", Buffer[Index]);
            if ((Index + 1) >= Length)
            {
                goto Finish;
            }

            AcpiOsPrintf (", ");
        }
        AcpiOsPrintf ("\n");
        AcpiDmIndent (Level + 2);

        i += 8;
    }

Finish:
    AcpiOsPrintf ("\n");
    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("}");
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmGpioCommon
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode common parts of a GPIO Interrupt descriptor
 *
 ******************************************************************************/

static void
AcpiDmGpioCommon (
    AML_RESOURCE            *Resource,
    UINT32                  Level)
{
    UINT32                  PinCount;
    UINT16                  *PinList;
    UINT8                   *VendorData;
    UINT32                  i;


    /* ResourceSource, ResourceSourceIndex, ResourceType */

    AcpiDmIndent (Level + 1);
    if (Resource->Gpio.ResSourceOffset)
    {
        AcpiUtPrintString (
            ACPI_ADD_PTR (char, Resource, Resource->Gpio.ResSourceOffset),
            ACPI_UINT8_MAX);
    }

    AcpiOsPrintf (", ");
    AcpiOsPrintf ("0x%2.2X, ", Resource->Gpio.ResSourceIndex);
    AcpiOsPrintf ("%s, ",
        AcpiGbl_ConsumeDecode [(Resource->Gpio.Flags & 1)]);

    /* Insert a descriptor name */

    AcpiDmDescriptorName ();
    AcpiOsPrintf (",");

    /* Dump the vendor data */

    if (Resource->Gpio.VendorOffset)
    {
        AcpiOsPrintf ("\n");
        AcpiDmIndent (Level + 1);
        VendorData = ACPI_ADD_PTR (UINT8, Resource,
            Resource->Gpio.VendorOffset);

        AcpiDmDumpRawDataBuffer (VendorData,
            Resource->Gpio.VendorLength, Level);
    }

    AcpiOsPrintf (")\n");

    /* Dump the interrupt list */

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("{   // Pin list\n");

    PinCount = ((UINT32) (Resource->Gpio.ResSourceOffset -
        Resource->Gpio.PinTableOffset)) /
        sizeof (UINT16);

    PinList = (UINT16 *) ACPI_ADD_PTR (char, Resource,
        Resource->Gpio.PinTableOffset);

    for (i = 0; i < PinCount; i++)
    {
        AcpiDmIndent (Level + 2);
        AcpiOsPrintf ("0x%4.4X%s\n", PinList[i], ((i + 1) < PinCount) ? "," : "");
    }

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("}\n");
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmGpioIntDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a GPIO Interrupt descriptor
 *
 ******************************************************************************/

static void
AcpiDmGpioIntDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{

    /* Dump the GpioInt-specific portion of the descriptor */

    /* EdgeLevel, ActiveLevel, Shared */

    AcpiDmIndent (Level);
    AcpiOsPrintf ("GpioInt (%s, %s, %s, ",
        AcpiGbl_HeDecode [(Resource->Gpio.IntFlags & 1)],
        AcpiGbl_LlDecode [(Resource->Gpio.IntFlags >> 1) & 1],
        AcpiGbl_ShrDecode [(Resource->Gpio.IntFlags >> 3) & 1]);

    /* PinConfig, DebounceTimeout */

    if (Resource->Gpio.PinConfig <= 3)
    {
        AcpiOsPrintf ("%s, ",
            AcpiGbl_PpcDecode[Resource->Gpio.PinConfig]);
    }
    else
    {
        AcpiOsPrintf ("0x%2.2X, ", Resource->Gpio.PinConfig);
    }
    AcpiOsPrintf ("0x%4.4X,\n", Resource->Gpio.DebounceTimeout);

    /* Dump the GpioInt/GpioIo common portion of the descriptor */

    AcpiDmGpioCommon (Resource, Level);
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmGpioIoDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a GPIO Interrupt descriptor
 *
 ******************************************************************************/

static void
AcpiDmGpioIoDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{

    /* Dump the GpioIo-specific portion of the descriptor */

    /* Shared, PinConfig */

    AcpiDmIndent (Level);
    AcpiOsPrintf ("GpioIo (%s, ",
        AcpiGbl_ShrDecode [(Resource->Gpio.IntFlags >> 3) & 1]);

    if (Resource->Gpio.PinConfig <= 3)
    {
        AcpiOsPrintf ("%s, ",
            AcpiGbl_PpcDecode[Resource->Gpio.PinConfig]);
    }
    else
    {
        AcpiOsPrintf ("0x%2.2X, ", Resource->Gpio.PinConfig);
    }

    /* DebounceTimeout, DriveStrength, IoRestriction */

    AcpiOsPrintf ("0x%4.4X, ", Resource->Gpio.DebounceTimeout);
    AcpiOsPrintf ("0x%4.4X, ", Resource->Gpio.DriveStrength);
    AcpiOsPrintf ("%s,\n",
        AcpiGbl_IorDecode [Resource->Gpio.IntFlags & 3]);

    /* Dump the GpioInt/GpioIo common portion of the descriptor */

    AcpiDmGpioCommon (Resource, Level);
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmGpioDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a GpioInt/GpioIo GPIO Interrupt/IO descriptor
 *
 ******************************************************************************/

void
AcpiDmGpioDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{
    UINT8                   ConnectionType;


    ConnectionType = Resource->Gpio.ConnectionType;

    switch (ConnectionType)
    {
    case AML_RESOURCE_GPIO_TYPE_INT:
        AcpiDmGpioIntDescriptor (Resource, Length, Level);
        break;

    case AML_RESOURCE_GPIO_TYPE_IO:
        AcpiDmGpioIoDescriptor (Resource, Length, Level);
        break;

    default:
        AcpiOsPrintf ("Unknown GPIO type\n");
        break;
    }
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmDumpSerialBusVendorData
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *
 * RETURN:      None
 *
 * DESCRIPTION: Dump optional serial bus vendor data
 *
 ******************************************************************************/

static void
AcpiDmDumpSerialBusVendorData (
    AML_RESOURCE            *Resource,
    UINT32                  Level)
{
    UINT8                   *VendorData;
    UINT32                  VendorLength;


    /* Get the (optional) vendor data and length */

    switch (Resource->CommonSerialBus.Type)
    {
    case AML_RESOURCE_I2C_SERIALBUSTYPE:

        VendorLength = Resource->CommonSerialBus.TypeDataLength -
            AML_RESOURCE_I2C_MIN_DATA_LEN;

        VendorData = ACPI_ADD_PTR (UINT8, Resource,
            sizeof (AML_RESOURCE_I2C_SERIALBUS));
        break;

    case AML_RESOURCE_SPI_SERIALBUSTYPE:

        VendorLength = Resource->CommonSerialBus.TypeDataLength -
            AML_RESOURCE_SPI_MIN_DATA_LEN;

        VendorData = ACPI_ADD_PTR (UINT8, Resource,
            sizeof (AML_RESOURCE_SPI_SERIALBUS));
        break;

    case AML_RESOURCE_UART_SERIALBUSTYPE:

        VendorLength = Resource->CommonSerialBus.TypeDataLength -
            AML_RESOURCE_UART_MIN_DATA_LEN;

        VendorData = ACPI_ADD_PTR (UINT8, Resource,
            sizeof (AML_RESOURCE_UART_SERIALBUS));
        break;

    default:
        return;
    }

    /* Dump the vendor bytes as a RawDataBuffer object */

    AcpiDmDumpRawDataBuffer (VendorData, VendorLength, Level);
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmI2cSerialBusDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a I2C serial bus descriptor
 *
 ******************************************************************************/

static void
AcpiDmI2cSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{
    UINT32                  ResourceSourceOffset;


    /* SlaveAddress, SlaveMode, ConnectionSpeed, AddressingMode */

    AcpiDmIndent (Level);
    AcpiOsPrintf ("I2cSerialBus (0x%4.4X, %s, 0x%8.8X,\n",
        Resource->I2cSerialBus.SlaveAddress,
        AcpiGbl_SmDecode [(Resource->I2cSerialBus.Flags & 1)],
        Resource->I2cSerialBus.ConnectionSpeed);

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("%s, ",
        AcpiGbl_AmDecode [(Resource->I2cSerialBus.TypeSpecificFlags & 1)]);

    /* ResourceSource is a required field */

    ResourceSourceOffset = sizeof (AML_RESOURCE_COMMON_SERIALBUS) +
        Resource->CommonSerialBus.TypeDataLength;

    AcpiUtPrintString (
        ACPI_ADD_PTR (char, Resource, ResourceSourceOffset),
        ACPI_UINT8_MAX);

    /* ResourceSourceIndex, ResourceUsage */

    AcpiOsPrintf (",\n");
    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("0x%2.2X, ", Resource->I2cSerialBus.ResSourceIndex);

    AcpiOsPrintf ("%s, ",
        AcpiGbl_ConsumeDecode [(Resource->I2cSerialBus.Flags & 1)]);

    /* Insert a descriptor name */

    AcpiDmDescriptorName ();
    AcpiOsPrintf (",\n");

    /* Dump the vendor data */

    AcpiDmIndent (Level + 1);
    AcpiDmDumpSerialBusVendorData (Resource, Level);
    AcpiOsPrintf (")\n");
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmSpiSerialBusDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a SPI serial bus descriptor
 *
 ******************************************************************************/

static void
AcpiDmSpiSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{
    UINT32                  ResourceSourceOffset;


    /* DeviceSelection, DeviceSelectionPolarity, WireMode, DataBitLength */

    AcpiDmIndent (Level);
    AcpiOsPrintf ("SpiSerialBus (0x%4.4X, %s, %s, 0x%2.2X,\n",
        Resource->SpiSerialBus.DeviceSelection,
        AcpiGbl_DpDecode [(Resource->SpiSerialBus.TypeSpecificFlags >> 1) & 1],
        AcpiGbl_WmDecode [(Resource->SpiSerialBus.TypeSpecificFlags & 1)],
        Resource->SpiSerialBus.DataBitLength);

    /* SlaveMode, ConnectionSpeed, ClockPolarity, ClockPhase */

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("%s, 0x%8.8X, %s,\n",
        AcpiGbl_SmDecode [(Resource->SpiSerialBus.Flags & 1)],
        Resource->SpiSerialBus.ConnectionSpeed,
        AcpiGbl_CpoDecode [(Resource->SpiSerialBus.ClockPolarity & 1)]);

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("%s, ",
        AcpiGbl_CphDecode [(Resource->SpiSerialBus.ClockPhase & 1)]);

    /* ResourceSource is a required field */

    ResourceSourceOffset = sizeof (AML_RESOURCE_COMMON_SERIALBUS) +
        Resource->CommonSerialBus.TypeDataLength;

    AcpiUtPrintString (
        ACPI_ADD_PTR (char, Resource, ResourceSourceOffset),
        ACPI_UINT8_MAX);

    /* ResourceSourceIndex, ResourceUsage */

    AcpiOsPrintf (",\n");
    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("0x%2.2X, ", Resource->SpiSerialBus.ResSourceIndex);

    AcpiOsPrintf ("%s, ",
        AcpiGbl_ConsumeDecode [(Resource->SpiSerialBus.Flags & 1)]);

    /* Insert a descriptor name */

    AcpiDmDescriptorName ();
    AcpiOsPrintf (",\n");

    /* Dump the vendor data */

    AcpiDmIndent (Level + 1);
    AcpiDmDumpSerialBusVendorData (Resource, Level);
    AcpiOsPrintf (")\n");
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmUartSerialBusDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a UART serial bus descriptor
 *
 ******************************************************************************/

static void
AcpiDmUartSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{
    UINT32                  ResourceSourceOffset;


    /* ConnectionSpeed, BitsPerByte, StopBits */

    AcpiDmIndent (Level);
    AcpiOsPrintf ("UartSerialBus (0x%8.8X, %s, %s,\n",
        Resource->UartSerialBus.DefaultBaudRate,
        AcpiGbl_BpbDecode [(Resource->UartSerialBus.TypeSpecificFlags >> 4) & 3],
        AcpiGbl_SbDecode [(Resource->UartSerialBus.TypeSpecificFlags >> 2) & 3]);

    /* LinesInUse, IsBigEndian, Parity, FlowControl */

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("0x%2.2X, %s, %s, %s,\n",
        Resource->UartSerialBus.LinesEnabled,
        AcpiGbl_EdDecode [(Resource->UartSerialBus.TypeSpecificFlags >> 7) & 1],
        AcpiGbl_PtDecode [Resource->UartSerialBus.Parity & 7],
        AcpiGbl_FcDecode [Resource->UartSerialBus.TypeSpecificFlags & 3]);

    /* ReceiveBufferSize, TransmitBufferSize */

    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("0x%4.4X, 0x%4.4X, ",
        Resource->UartSerialBus.RxFifoSize,
        Resource->UartSerialBus.TxFifoSize);

    /* ResourceSource is a required field */

    ResourceSourceOffset = sizeof (AML_RESOURCE_COMMON_SERIALBUS) +
        Resource->CommonSerialBus.TypeDataLength;

    AcpiUtPrintString (
        ACPI_ADD_PTR (char, Resource, ResourceSourceOffset),
        ACPI_UINT8_MAX);

    /* ResourceSourceIndex, ResourceUsage */

    AcpiOsPrintf (",\n");
    AcpiDmIndent (Level + 1);
    AcpiOsPrintf ("0x%2.2X, ", Resource->UartSerialBus.ResSourceIndex);

    AcpiOsPrintf ("%s, ",
        AcpiGbl_ConsumeDecode [(Resource->UartSerialBus.Flags & 1)]);

    /* Insert a descriptor name */

    AcpiDmDescriptorName ();
    AcpiOsPrintf (",\n");

    /* Dump the vendor data */

    AcpiDmIndent (Level + 1);
    AcpiDmDumpSerialBusVendorData (Resource, Level);
    AcpiOsPrintf (")\n");
}


/*******************************************************************************
 *
 * FUNCTION:    AcpiDmSerialBusDescriptor
 *
 * PARAMETERS:  Resource            - Pointer to the resource descriptor
 *              Length              - Length of the descriptor in bytes
 *              Level               - Current source code indentation level
 *
 * RETURN:      None
 *
 * DESCRIPTION: Decode a I2C/SPI/UART serial bus descriptor
 *
 ******************************************************************************/

void
AcpiDmSerialBusDescriptor (
    AML_RESOURCE            *Resource,
    UINT32                  Length,
    UINT32                  Level)
{

    SerialBusResourceDispatch [Resource->CommonSerialBus.Type] (
        Resource, Length, Level);
}

#endif

