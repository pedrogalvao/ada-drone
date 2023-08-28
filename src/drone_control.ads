with AWS.Response;
with AWS.Status;
with AWS.Server;
with AWS.Parameters;

package Drone_Control is

   function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data;

end Drone_Control;