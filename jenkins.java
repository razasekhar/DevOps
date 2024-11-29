import org.jenkinsci.plugins.workflow.job.WorkflowJob;
import hudson.model.Result;
import hudson.model.Hudson;
import jenkins.model.Jenkins;
import java.net.URL;

public class JenkinsPipelineTrigger {

    public static void main(String[] args) {
        try {
            // Connect to Jenkins server
            String jenkinsUrl = "http://localhost:8080"; // Change this to your Jenkins URL
            String jobName = "YourJobName"; // Name of the Jenkins pipeline job
            String credentialsId = "5e8a3906-a65b-4f3e-a05c-488d0cd90fdd"; // Replace with actual credentials ID

            // Create Jenkins instance
            Jenkins jenkins = Jenkins.getInstance();

            // Access the Jenkins job
            WorkflowJob job = (WorkflowJob) jenkins.getItem(jobName);

            if (job != null) {
                // Trigger the job (similar to calling `pipeline { agent any }`)
                System.out.println("Triggering Jenkins job...");
                job.scheduleBuild2(0).waitForStart();
                
                // You can add logic to monitor the job's build status
                job.getLastBuild().getResult();
                System.out.println("Job triggered successfully!");

            } else {
                System.out.println("Jenkins job not found: " + jobName);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
