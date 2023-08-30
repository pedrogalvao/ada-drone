with Ada.Text_IO; use Ada.Text_IO;

package body Drone_Control is


function Calculate_Force (Position:Float; Speed: Float; Target_Position: Float) return Float is
begin
    return ((Target_Position - Position) - 2.0 * Speed);
end Calculate_Force;

function "+"(Left, Right: Vec3) return Vec3 is 
    result: Vec3;
begin
    result := (Left.X + Right.X, Left.Y + Right.Y, Left.Z + Right.Z);
    return result;
end "+";

function "-"(Left, Right: Vec3) return Vec3 is 
    result: Vec3;
begin
    result := (Left.X - Right.X, Left.Y - Right.Y, Left.Z - Right.Z);
    return result;
end "-";

function "*"(Left : Float; Right: Vec3) return Vec3 is 
    result: Vec3;
begin
    result := (Left * Right.X, Left * Right.Y, Left * Right.Z);
    return result;
end "*";

function "/"(Left : Vec3; Right: Float) return Vec3 is 
    result: Vec3;
begin
    result := (Left.X / Right, Left.Y / Right, Left.Z / Right);
    return result;
end "/";

function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data is
    pragma Unreferenced (Request);
    Current_Position : Vec3;
    Current_Speed : Vec3;
    Time_Interval : Float;
    Second_Last_Index : Natural;
    Force : Vec3;
    Target_Position : Vec3 := (X=>10.0, Y=>10.0, Z=>10.0);
begin
    
    Current_Position := (
                    X => Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x")),
                    Y => Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y")),
                    Z => Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"))
                );

    timestamps.append(Clock);

    if timestamps.Last_Index > 1 then 
        Second_Last_Index := Natural(Integer(timestamps.Last_Index) - 1);
        Time_Interval := Float(timestamps.Last_Element - timestamps(Second_Last_Index));
        Current_Speed := (Current_Position - positions.Last_Element) / Time_Interval;
    else
        Current_Speed := (0.0, 0.0, 0.0);
    end if;

    positions.Append(Current_Position);
    speeds.Append(Current_Speed);

    Put_Line ("X: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x"));
    Put_Line ("Y: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Put_Line ("Z: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"));

    Put_Line("Force_X: " & Float'Image(Force.X));
    Put_Line("Force_Y: " & Float'Image(Force.Y));
    Put_Line("Force_Z: " & Float'Image(Force.Z));
    Force := (Target_Position - Current_Position) - 2.0 * Current_Speed + (0.0, 9.81, 0.0);
    return AWS.Response.Build ("text/json", "{ ""force"" :[" 
                                    & Float'Image(Force.X) & ", " 
                                    & Float'Image(Force.Y) & ", " 
                                    & Float'Image(Force.Z) & "]}");
end HW_CB;

end Drone_Control;