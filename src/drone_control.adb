with Ada.Text_IO; use Ada.Text_IO;

package body Drone_Control is

function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data is
    pragma Unreferenced (Request);
    Position_X : Float;
    Position_Y : Float;
    Position_Z : Float;
    Current_Postition : Vec3;
    Current_Speed : Vec3;
    Time_Interval : Float;
    Second_Last_Index : Natural;
    Force_Y : Float;
begin
    
    Position_X := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x"));
    Position_Y := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Position_Z := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"));

    timestamps.append(Clock);

    Current_Postition := (X=>Position_X, Y=>Position_Y, Z=>Position_Z);

    if timestamps.Last_Index > 1 then 
        Second_Last_Index := Natural(Integer(timestamps.Last_Index) - 1);
        Time_Interval := Float(timestamps.Last_Element - timestamps(Second_Last_Index));
        Current_Speed := (
                            X => (Position_X - positions.Last_Element.X) / Time_Interval, 
                            Y => (Position_Y - positions.Last_Element.Y) / Time_Interval, 
                            Z => (Position_Z - positions.Last_Element.Z) / Time_Interval
                        );
    else
        Current_Speed := (
                            X => 0.0,
                            Y => 0.0,
                            Z => 0.0
                        );
    end if;

    positions.Append(Current_Postition);
    speeds.Append(Current_Speed);

    Put_Line ("Height: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Force_Y := 9.81 + ((10.0 - Position_Y) - 2.0 * Current_Speed.Y);
    Put_Line("Force_Y: " & Float'Image(Force_Y));

    return AWS.Response.Build ("text/json", "{ ""force"" :[0, " & Float'Image(Force_Y) & ", 0]}");
end HW_CB;

end Drone_Control;